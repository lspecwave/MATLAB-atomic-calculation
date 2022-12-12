using System;
using System.Collections.Generic;
using System.Text;
using DataStructures;
using System.Threading;
using DataStructures.Timing;

namespace AtticusServer
{
    /// <summary>
    /// This class mimicks some of the functionality of the NI "task" class, but is used to drive various GPIB devices.
    /// This is where all of the gpib-device-specific code is stored.
    /// This class also deals with software pseudo-realtiming of gpib commands.
    /// </summary>
    public class GpibTask : DataStructures.Timing.SoftwareClockSubscriber
    {

        public event NationalInstruments.DAQmx.TaskDoneEventHandler Done;

        private struct GpibCommand
        {
            public string command;
            /// <summary>
            /// Time during the sequence at which the command is to be output.
            /// The unit is "ticks".
            /// 1 tick = 100 ns.
            /// </summary>
            public long commandTime;

            public GpibCommand(string comm, long commTime)
            {
                this.command = comm;
                this.commandTime = commTime;
            }
        }

        public override string ToString()
        {
            return "GPIB Logical Channel " + logicalChannelID + " ";
        }

        private List<GpibCommand> commandBuffer;
        private NationalInstruments.NI4882.Device device;
        private HardwareChannel.HardwareConstants.GPIBDeviceType deviceType;
        private int logicalChannelID;

        public GpibTask(NationalInstruments.NI4882.Device device)
        {
            this.device = device;
        }


        long postRetriggerTime = 100; // corresponds to 10us.
        // A workaround to issue when using software timed groups in 
        // fpga-retriggered words

        // the workaround: delay the software timed group by an immesurable amount
        // if it is started in a retriggered word


        // This functionality is sort of somewhat duplicated in sequencedata.generatebuffers. It would be good
        // to come up with a more coherent framework to do these sorts of operations.

        public bool generateBuffer(SequenceData sequence, DeviceSettings deviceSettings, HardwareChannel hc, int logicalChannelID, List<GpibRampCommandConverter> commandConverters)
        {
            this.logicalChannelID = logicalChannelID;
            this.deviceType = hc.GpibDeviceType;
            commandBuffer = new List<GpibCommand>();


            if (deviceSettings.StartTriggerType != DeviceSettings.TriggerType.SoftwareTrigger)
            {
                throw new Exception("GPIB devices must have a software start trigger."); 
            }

            // start by adding the initialization string to the command buffer
            // this does nothing for unknown device types
            // Modified by REO 11/25/08: Null strings produce errors if written to device, so check
            if(HardwareChannel.HardwareConstants.gpibInitializationCommands[(int)deviceType]!= null)
                commandBuffer.Add(new GpibCommand(HardwareChannel.HardwareConstants.gpibInitializationCommands[(int)deviceType], 0));


           if (deviceType == HardwareChannel.HardwareConstants.GPIBDeviceType.Unknown)
           {
               foreach (GpibRampCommandConverter conv in commandConverters)
               {
                   //Modified by REO 11/25/08: Null strings produce errors if written to device, so check
                   if (deviceSettings.DeviceDescription.Contains(conv.DeviceIdentifierSubstring) && conv.InitializationCommand != null)
                       commandBuffer.Add(new GpibCommand(AddNewlineCharacters(conv.InitializationCommand), 0));
               }
           }

           int currentStepIndex = - 1;

           //measured in ticks. 1 tick = 100 ns.
           long currentTime = 0;

           
           // This functionality is sort of somewhat duplicated in sequencedata.generatebuffers. It would be good
           // to come up with a more coherent framework to do these sorts of operations.
           while (true)
           {
               currentStepIndex++;

               if (currentStepIndex >= sequence.TimeSteps.Count)
                   break;

               TimeStep currentStep = sequence.TimeSteps[currentStepIndex];

               if (!currentStep.StepEnabled)
                   continue;

               if (currentStep.GpibGroup == null || !currentStep.GpibGroup.channelEnabled(logicalChannelID))
               {
                   currentTime += Shared.SecondsToTicks(currentStep.StepDuration.getBaseValue());
                   continue;
               }

               long postTime = 0;
               if (currentStep.RetriggerOptions.WaitForRetrigger)
                   postTime = postRetriggerTime;

               // determine the index of the next step in which this channel has an action
               int nextEnabledStepIndex = sequence.findNextGpibChannelEnabledTimestep(currentStepIndex, logicalChannelID);

               long groupDuration = Shared.SecondsToTicks(sequence.timeBetweenSteps(currentStepIndex, nextEnabledStepIndex));

               // now take action:

               GPIBGroupChannelData channelData = currentStep.GpibGroup.getChannelData(logicalChannelID);
            
               if (channelData.DataType == GPIBGroupChannelData.GpibChannelDataType.raw_string) {
                       // Raw string commands just get added 
                       string stringWithCorrectNewlines = AddNewlineCharacters(channelData.RawString);

                       commandBuffer.Add(new GpibCommand(  stringWithCorrectNewlines, currentTime + postTime));
               }
               else if (channelData.DataType == GPIBGroupChannelData.GpibChannelDataType.voltage_frequency_waveform)
               {
                   GpibRampCommandConverter rampConverter = null;
                   switch (hc.GpibDeviceType)
                   {
                       case HardwareChannel.HardwareConstants.GPIBDeviceType.Unknown:
                           {
                               foreach (GpibRampCommandConverter conv in commandConverters)
                               {
                                   if (deviceSettings.DeviceDescription.Contains(conv.DeviceIdentifierSubstring))
                                       rampConverter = conv;
                               }
                               if (rampConverter == null)
                               {
                                   throw new Exception("Voltage/frequency ramp not supported for unknown gpib device " + hc.ToString() + ".");
                               }
                               
                           }
                           break;
                       case HardwareChannel.HardwareConstants.GPIBDeviceType.Agilent_ESG_SIG_Generator:
                           {
                               rampConverter = ESG_SeriesRampConverter;
                           }
                           break;
                   }
                   double[] amplitudeArray;
                   double[] frequencyArray;

                   // get amplitude and frequency value arrays
                   int nSamples = (int)(Shared.TicksToSeconds(groupDuration) * (double)deviceSettings.SampleClockRate);
                   double secondsPerSample = Shared.TicksToSeconds(groupDuration) / (double) nSamples;

                   amplitudeArray = channelData.volts.getInterpolation(nSamples, 0, Shared.TicksToSeconds(groupDuration), sequence.Variables, sequence.CommonWaveforms);
                   frequencyArray = channelData.frequency.getInterpolation(nSamples, 0, Shared.TicksToSeconds(groupDuration), sequence.Variables, sequence.CommonWaveforms);

                   List<DoubleIntPair> amplitudeIndexPairs = ConvertArrayToIndexValuePairs(amplitudeArray);
                   List<DoubleIntPair> frequencyIndexPairs = ConvertArrayToIndexValuePairs(frequencyArray);
                   int amplitudeIndex = 0;
                   int frequencyIndex = 0;
                   for (int i = 0; i < nSamples; i++)
                   {

                       bool amplitudeMatch = false;
                       bool frequencyMatch = false;

                       // determine if there is either a amplitude or frequency data point for this sample number
                       if (amplitudeIndex < amplitudeIndexPairs.Count)
                           amplitudeMatch = amplitudeIndexPairs[amplitudeIndex].myInt == i;
                       if (frequencyIndex < frequencyIndexPairs.Count)
                           frequencyMatch = frequencyIndexPairs[frequencyIndex].myInt == i;

                       if (amplitudeIndex >= amplitudeIndexPairs.Count && frequencyIndex >= frequencyIndexPairs.Count)
                           break;

                       if (amplitudeMatch || frequencyMatch)
                       {
                           string command = "";
                           if (amplitudeMatch)
                           {
                               command += rampConverter.amplitudeCommand(amplitudeIndexPairs[amplitudeIndex].myDouble);
                               amplitudeIndex++;
                           }
                           if (frequencyMatch)
                           {
                               command += rampConverter.frequencyCommand(frequencyIndexPairs[frequencyIndex].myDouble);
                               frequencyIndex++;
                           }

                           long commandTime = currentTime + Shared.SecondsToTicks((double)i * secondsPerSample) + postTime;

                          
                           commandBuffer.Add(new GpibCommand(command, commandTime));
                       }


                   }


               }
               else if (channelData.DataType == GPIBGroupChannelData.GpibChannelDataType.string_param_string)
               {
                   if (channelData.StringParameterStrings != null)
                   {
                       foreach (StringParameterString sps in channelData.StringParameterStrings)
                       {
                           string commandWithCorrectNewlines = AddNewlineCharacters(sps.ToString());
                           commandBuffer.Add(new GpibCommand(commandWithCorrectNewlines, currentTime + postTime));
                       }
                   }
               }

               currentTime += Shared.SecondsToTicks(currentStep.StepDuration.getBaseValue());            
           }

           return true;
        }

        long taskStartTime;
        int currentCommand;


        public bool reachedTime(uint elasped_ms, int priority)
        {
            return runTick(elasped_ms);
        }

        public bool handleExceptionOnClockThread(Exception e)
        {
            return false;
        }

        private bool isDone = false;

        public bool runTick(uint elasped_ms)
        {
            if (isDone)
                return false;
            /* try
             {*/

            long elaspedTime = DataStructures.Timing.Shared.MillisecondsToTicks(elasped_ms);
                if (currentCommand >= commandBuffer.Count)
                {
                    disposeDevice();
                    if (this.Done != null)
                    {
                        this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(null));
                    }
                    isDone = true;
                    return false;
                }
                while (elaspedTime >= commandBuffer[currentCommand].commandTime)
                {
                    device.Write(commandBuffer[currentCommand].command);

                    AtticusServer.server.messageLog(this, new MessageEvent("Wrote GPIB command " + commandBuffer[currentCommand].command, 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.GPIB));

                    currentCommand++;
                    if (currentCommand >= commandBuffer.Count)
                        break;

                    if (currentCommand >= commandBuffer.Count) // we've run out of new commands, so disable the timer.
                    {
                        disposeDevice();
                        if (this.Done != null)
                        {
                            this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(null));
                        }
                        isDone = true;
                        return false;
                    }
                }
                
            
            //}
            /*catch (Exception e)
            {
                if (e is ThreadAbortException)
                {
                    disposeDevice();
                    if (this.Done != null)
                    {
                        this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(null));
                    }
                }
                else
                {
                    AtticusServer.server.messageLog(this, new MessageEvent("Caught an exception while running GPIB task for GPIB channel " + logicalChannelID + ": " + e.Message + e.StackTrace));
                    AtticusServer.server.messageLog(this, new MessageEvent("Aborting GPIB task."));
                    MainServerForm.instance.DisplayError = true;
                    disposeDevice();
                    if (this.Done != null)
                    {
                        this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(e));
                    }
                }
            }*/
                return true;
        }

        private void disposeDevice()
        {
            if (device != null)
            {
                device.Dispose();
                device = null;
            }
        }

        

        private struct DoubleIntPair
        {
            public double myDouble;
            public int myInt;
            public DoubleIntPair(double myDouble, int myInt)
            {
                this.myDouble = myDouble;
                this.myInt = myInt;
            }
        }

        /// <summary>
        /// This method converts an array of doubles into a list of index-value pairs. 
        /// </summary>
        /// <param name="array"></param>
        /// <returns></returns>
        private List<DoubleIntPair> ConvertArrayToIndexValuePairs(double[] array)
        {
            if (array == null)
                return null;
            List<DoubleIntPair> ans = new List<DoubleIntPair>();

            if (array.Length == 0)
                return ans;

            ans.Add(new DoubleIntPair(array[0], 0));
            double lastValue = array[0];
            for (int i = 1; i < array.Length; i++)
            {
                if (array[i] != lastValue)
                {
                    ans.Add(new DoubleIntPair(array[i], i));
                    lastValue = array[i];
                }
            }
            return ans;
        }

        public static string AddNewlineCharacters(string input)
        {
            if (input == null)
                return null;
            return input.Replace("\\n", "\n").Replace("\\r", "\r");
        }




        private static GpibRampCommandConverter ESG_SeriesRampConverter = new GpibRampCommandConverter(
            ":POW:AMPL ", " V\n", ":FREQ ", " Hz\n", "");

        public bool providerTimerFinished(int priority)
        {
            return true;
        }
        
    }
}

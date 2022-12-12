using System;
using System.Collections.Generic;
using System.Text;
using DataStructures;
using InstrumentDriverInterop.Ivi;
using System.Threading;

namespace AtticusServer
{
    class RfsgTask : DataStructures.Timing.SoftwareClockSubscriber
    {
        private static Dictionary<string, niRFSG> rfsgDevices;
        private static Dictionary<niRFSG, bool> rfsgDeviceInitiated;
        private niRFSG rfsgDevice;
        private List<RFSGCommand> commandBuffer;
        public event NationalInstruments.DAQmx.TaskDoneEventHandler Done;
        int currentCommand = 0;
        long taskStartTime;
        int channelID;
        

        private struct RFSGCommand
        {
            public enum CommandType { AmplitudeFrequency, EnableOutput, DisableOutput, Initiate, Abort };
            public CommandType commandType;

            public double frequency;
            public double amplitude;

            /// <summary>
            /// time, in ticks (100ns intervals. 10 ticks = 1us. 10000 = 1ms) at which command is to be output, relative to
            /// sequence start
            /// </summary>
            public long commandTime;
        
        }

        double Vpp_to_dBm(double vpp)
        {
            return 4.0 + 20.0 * Math.Log10(vpp);
        }

        long seconds_to_ticks(double seconds)
        {
            return (long) (seconds * 10000000);
        }

        double ticks_to_seconds(long ticks)
        {
            return ticks / 10000000;
        }

        public RfsgTask(SequenceData sequence, SettingsData settings, int channelID, string rfsgDeviceName, DeviceSettings deviceSettings)
        {
            if (!settings.logicalChannelManager.GPIBs.ContainsKey(channelID))
            {
                throw new InvalidDataException("Attempted to create an rfsg task with channel id " + channelID + ", which does not exist in the settings as a gpib channel.");
            }

            this.channelID = channelID;




            int currentStepIndex = -1;

            //measured in ticks. 1 tick = 100 ns.
            long currentTime = 0;

            commandBuffer = new List<RFSGCommand>();

            if (deviceSettings.AutoInitate)
            {
                RFSGCommand com = new RFSGCommand();
                com.commandTime = 0;
                com.commandType = RFSGCommand.CommandType.Initiate;
                commandBuffer.Add(com);
            }

            if (deviceSettings.AutoEnable)
            {
                RFSGCommand com = new RFSGCommand();
                com.commandTime = 0;
                com.commandType = RFSGCommand.CommandType.EnableOutput;
                commandBuffer.Add(com);
            }

            long postRetriggerTime = 100; // corresponds to 10us.
            // A workaround to issue when using software timed groups in 
            // fpga-retriggered words

            // the workaround: delay the software timed group by an immesurable amount
            // if it is started in a retriggered word


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

                if (currentStep.GpibGroup == null || !currentStep.GpibGroup.channelEnabled(channelID))
                {
                    currentTime += seconds_to_ticks(currentStep.StepDuration.getBaseValue());
                    continue;
                }

                long postTime = 0;
                if (currentStep.RetriggerOptions.WaitForRetrigger)
                    postTime = postRetriggerTime;

                // determine the index of the next step in which this channel has an action
                int nextEnabledStepIndex = sequence.findNextGpibChannelEnabledTimestep(currentStepIndex, channelID);

                long groupDuration = seconds_to_ticks(sequence.timeBetweenSteps(currentStepIndex, nextEnabledStepIndex));

                // now take action:

                GPIBGroupChannelData channelData = currentStep.GpibGroup.getChannelData(channelID);

                if (channelData.DataType == GPIBGroupChannelData.GpibChannelDataType.raw_string)
                {

                    throw new Exception("Not yet implemented.");
                    /*

                    // Raw string commands just get added 
                    string stringWithCorrectNewlines = AddNewlineCharacters(channelData.RawString);

                    commandBuffer.Add(new GpibCommand(stringWithCorrectNewlines, currentTime));*/
                }
                else if (channelData.DataType == GPIBGroupChannelData.GpibChannelDataType.voltage_frequency_waveform)
                {

                    double[] amplitudeArray;
                    double[] frequencyArray;

                    // get amplitude and frequency value arrays
                    int nSamples = (int)(ticks_to_seconds(groupDuration) * (double)deviceSettings.SampleClockRate);
                    double secondsPerSample = ticks_to_seconds(groupDuration) / (double)nSamples;

                    amplitudeArray = channelData.volts.getInterpolation(nSamples, 0, ticks_to_seconds(groupDuration), sequence.Variables, sequence.CommonWaveforms);
                    frequencyArray = channelData.frequency.getInterpolation(nSamples, 0, ticks_to_seconds(groupDuration), sequence.Variables, sequence.CommonWaveforms);

                    double lastFreq = Double.MinValue;
                    double lastAmp = Double.MinValue;

                    for (int i = 0; i < nSamples; i++)
                    {
                        double currentFreq = frequencyArray[i];
                        double currentAmp = amplitudeArray[i];
                        if (currentFreq != lastFreq || currentAmp != lastAmp)
                        {
                            RFSGCommand command = new RFSGCommand();
                            command.commandType = RFSGCommand.CommandType.AmplitudeFrequency;
                            command.frequency = currentFreq;
                            command.amplitude = Vpp_to_dBm(currentAmp);
                            command.commandTime = (long)(currentTime + i * secondsPerSample * 10000000) + postTime;

                            commandBuffer.Add(command);
                        }
                        lastAmp = currentAmp;
                        lastFreq = currentFreq;

                    }
                }

                else if (channelData.DataType == GPIBGroupChannelData.GpibChannelDataType.string_param_string)
                {
                    foreach (StringParameterString sps in channelData.StringParameterStrings)
                    {
                        string clean = sps.Prefix.Trim().ToUpper();
                        if (clean == "ENABLE")
                        {
                            RFSGCommand com = new RFSGCommand();
                            com.commandType = RFSGCommand.CommandType.EnableOutput;
                            com.commandTime = currentTime + postTime;
                            commandBuffer.Add(com);
                        }

                        if (clean == "DISABLE")
                        {
                            RFSGCommand com = new RFSGCommand();
                            com.commandType = RFSGCommand.CommandType.DisableOutput;
                            com.commandTime = currentTime + postTime;
                            commandBuffer.Add(com);
                        }

                        if (clean == "ABORT")
                        {
                            RFSGCommand com = new RFSGCommand();
                            com.commandType = RFSGCommand.CommandType.Abort;
                            com.commandTime = currentTime + postTime;
                            commandBuffer.Add(com);
                        }

                        if (clean == "INITIATE")
                        {
                            RFSGCommand com = new RFSGCommand();
                            com.commandType = RFSGCommand.CommandType.Initiate;
                            com.commandTime = currentTime + postTime;
                            commandBuffer.Add(com);
                        }       
                    }
                }

                currentTime += seconds_to_ticks(currentStep.StepDuration.getBaseValue());
            }


            if (rfsgDevices == null)
            {
                rfsgDevices = new Dictionary<string, niRFSG>();
                rfsgDeviceInitiated = new Dictionary<niRFSG, bool>();
            }

            if (rfsgDevices.ContainsKey(rfsgDeviceName))
            {
                rfsgDevice = rfsgDevices[rfsgDeviceName];
            }
            else
            {

                try
                {
                    rfsgDevice = new niRFSG(rfsgDeviceName, true, false);
                }
                catch (Exception e)
                {
                    throw new InvalidDataException("Caught exception when attempting to instantiate an rfsg device named " + rfsgDeviceName + ". Maybe a device by this name does not exist? Exception message: " + e.Message);
                }
                rfsgDevices.Add(rfsgDeviceName, rfsgDevice);
                rfsgDeviceInitiated.Add(rfsgDevice, false);
            }


            if (deviceSettings.MasterTimebaseSource != null && deviceSettings.MasterTimebaseSource != "")
            {
                rfsgDevice.ConfigureRefClock(deviceSettings.MasterTimebaseSource, 10000000);
            }
        
        }


        public bool reachedTime(uint time_ms, int priority)
        {
            return runTick(time_ms);
        }

        public bool handleExceptionOnClockThread(Exception e)
        {
            return false;
        }

        /// <summary>
        /// This function is copied from GPIBTask, with small modifications.
        /// </summary>
        public bool runTick(uint elasped_ms)
        {
            //try
            // {
            long elaspedTime = DataStructures.Timing.Shared.MillisecondsToTicks(elasped_ms);


            if (currentCommand >= commandBuffer.Count)
            {
                if (this.Done != null)
                {
                    this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(null));
                }
                return false;
            }
            while (elaspedTime >= commandBuffer[currentCommand].commandTime)
            {
                outputRfsgCommand(commandBuffer[currentCommand]);
                currentCommand++;

                if (currentCommand >= commandBuffer.Count) // we've run out of new commands, so disable the timer.
                {

                    if (this.Done != null)
                    {
                        this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(null));
                    }
                    return false;
                }
            }

            return true;


            /* }
             catch (Exception e)
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
                     AtticusServer.server.messageLog(this, new MessageEvent("Caught an exception while running RFSG task for GPIB channel " + channelID + ": " + e.Message + e.StackTrace));
                     AtticusServer.server.messageLog(this, new MessageEvent("Aborting RFSG task."));
                     MainServerForm.instance.DisplayError = true;
                     disposeDevice();
                     if (this.Done != null)
                     {
                         this.Done(this, new NationalInstruments.DAQmx.TaskDoneEventArgs(e));
                     }
                 }
             }*/
        }

        private void outputRfsgCommand(RFSGCommand command)
        {
            bool success = false;
            switch (command.commandType)
            {
                case RFSGCommand.CommandType.AmplitudeFrequency:
                    rfsgDevice.ConfigureRF(command.frequency, command.amplitude);

                    AtticusServer.server.messageLog(this, new MessageEvent("RFSG commanded to frequence(Hz)/amplitude(dBm) " + command.frequency + "/" + command.amplitude, 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));

                    break;
                case RFSGCommand.CommandType.EnableOutput:
                    try
                    {
                        rfsgDevice.ConfigureOutputEnabled(true);
                        success = true;
                    }
                    catch (Exception) { }


                    if (success)
                        AtticusServer.server.messageLog(this, new MessageEvent("RFSG commanded to enable output", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));
                    else
                        AtticusServer.server.messageLog(this, new MessageEvent("RSG command to enable output gave error. Output probably already enabled.", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));

                    break;

                case RFSGCommand.CommandType.DisableOutput:
                    try
                    {
                        rfsgDevice.ConfigureOutputEnabled(false);
                        success = true;
                    }
                    catch (Exception)
                    {
                    }

                    if (success)
                        AtticusServer.server.messageLog(this, new MessageEvent("RFSG commanded to disable output", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));
                    else
                        AtticusServer.server.messageLog(this, new MessageEvent("RFSG command to disable output gave error. Output probably already disabled.", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));

                    break;

                case RFSGCommand.CommandType.Initiate:
                    {

                        if (rfsgDeviceInitiated[rfsgDevice])
                        {

                            AtticusServer.server.messageLog(this, new MessageEvent("RFSG device believed to be initiated already. Skipping initiate command.", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));
                            break;
                        }

                        try
                        {
                            rfsgDevice.Initiate();
                            success = true;
                        }
                        catch (Exception)
                        {
                        }

                        if (success)
                            rfsgDeviceInitiated[rfsgDevice] = true;
                        else
                            rfsgDeviceInitiated[rfsgDevice] = false;


                        if (success)
                            AtticusServer.server.messageLog(this, new MessageEvent("RFSG commanded to initiate output (enter committed state)", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));
                        else
                            AtticusServer.server.messageLog(this, new MessageEvent("RFSG command to initiate device gave error. Device probably already initiated.", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));


                    }
                    break;


                case RFSGCommand.CommandType.Abort:

                    rfsgDevice.Abort();

                    AtticusServer.server.messageLog(this, new MessageEvent("RFSG commanded to abort output (enter configuration state)", 1, MessageEvent.MessageTypes.Log, MessageEvent.MessageCategories.RFSG));

                    rfsgDeviceInitiated[rfsgDevice] = false;
                    break;
            }
        }


        public bool providerTimerFinished(int priority)
        {
            return true;
        }

    }
}

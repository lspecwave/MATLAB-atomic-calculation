import serial
import time
import influxdb
import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS
from datetime import datetime
import socket

def timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def open_plc_port():
    """
    打开PLC对应的TCP端口，返回socket对象。
    
    默认PLC的IP地址为 192.168.124.53，端口为 10000。
    此函数不需要输入参数。
    """
    plc_ip = "192.168.124.53"
    plc_port = 10000
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)  # 设置超时时间为5秒
        s.connect((plc_ip, plc_port))
        # print(f"成功连接至PLC {plc_ip}:{plc_port}")
        return s
    except Exception as e:
        print(f"打开PLC端口失败: {e}")
        return None

def send_command_and_calculate():
    """
    发送命令给PLC，读取返回数据，并解析出对应字段后换算得到
    Temperature和Pressure。
    
    发送的命令为 "01 04 00 00 00 02 71 CB"。  
    从返回值中提取第7-10位（字段1）和第11-14位（字段2），
    转换为10进制后，按以下线性换算公式计算：
    
        Temperature = 100 * ((字段1 - 4000) / 16000)
        Pressure    = 2.5 * ((字段2 - 4000) / 16000)
    
    此函数没有输入参数，输出为Temperature和Pressure。
    """
    command_hex = "01 04 00 00 00 02 71 CB"
    
    # 打开PLC端口
    plc_socket = open_plc_port()
    if plc_socket is None:
        print("无法建立PLC连接，退出操作。")
        return None, None
    
    try:
        # 发送命令
        command_bytes = bytes.fromhex(command_hex)
        plc_socket.sendall(command_bytes)
        # print(f"发送命令: {command_hex}")

        # 接收响应数据（接收缓冲区为1024字节，根据需要调整）
        response = plc_socket.recv(1024)
        if not response:
            print("未接收到响应数据")
            return None, None

        # 将返回的字节数据转换为大写的十六进制字符串
        response_hex = response.hex().upper()
        # print(f"接收到的响应: {response_hex}")
    
        # 检查数据长度是否足够，至少需要14个字符（对应7个字节）
        if len(response_hex) < 14:
            print("返回数据长度不足，无法提取指定字段")
            return None, None
        
        # 提取第7-10位和第11-14位
        # 注意：字符串索引从0开始，第7-10位对应索引 [6:10]，
        #       第11-14位对应索引 [10:14]
        field1_hex = response_hex[6:10]
        field2_hex = response_hex[10:14]
        # print(f"提取字段1（第7-10位 十六进制）：{field1_hex}")
        # print(f"提取字段2（第11-14位 十六进制）：{field2_hex}")

        # 将字段转换为10进制
        value1 = int(field1_hex, 16)
        value2 = int(field2_hex, 16)
        # print(f"字段1转换为10进制：{value1}")
        # print(f"字段2转换为10进制：{value2}")

        # 根据换算公式计算 Temperature 和 Pressure
        Temperature = 100 * ((value1 - 4000) / 16000)
        Pressure = 2.5 * ((value2 - 4000) / 16000)
        # print(f"计算得到: Temperature = {Temperature:.2f}, Pressure = {Pressure:.2f}")
        
        return Temperature, Pressure

    except Exception as e:
        print(f"处理过程中出现错误: {e}")
        return None, None
    finally:
        plc_socket.close()

# Data base information
bucket = "Yb-II"
org = "USTC"
#token = "KmkWBqQI0FNtW6sh9M5X0pilCK6smn29ttUdSxHNPu4cnQfgM66uCJTRlK2qF_VS095mj7-Xz2-Ct_brM_CLmQ=="
token = "Og1uW51NTh4as1dcp9SmFjHDr63bQpHhBvOHpBa6z93psFQ30IxPd1vBub9MslpFH5eJp0jOl2gVVuBMR8gZoA=="
# Store the URL of your InfluxDB instance
url="http://110.42.229.58:8086"
client = influxdb_client.InfluxDBClient(
   url=url,
   token=token,
   org=org,
   timeout=3000
)
# SYNCHRONOUS method
write_api = client.write_api(write_options=SYNCHRONOUS)

#
def writedata(p):
   # Input : data str , inform of "measurement,tag1=xxx,tag2=xxx,...tagn=xxx value1=x1,value2=x2" e.g. "testvalue,location=basement1,test=real value0=76"
   write_api.write(bucket=bucket, org=org, record=p)



def read_rpv_value(port='COM7', baudrate=19200, timeout=2):
    """
    通过串口发送 "RPV 3" 命令，读取返回字符串并提取第二个数值（如 5.8000E-12）
    返回浮点数，失败返回 None
    """
    try:
        # 打开串口
        ser = serial.Serial(port, baudrate, timeout=timeout)
        # 发送指令（若设备需要换行符，可将 cmd 改为 "RPV 3\r\n"）
        cmd = "RPV 3\r\n"
        ser.write(cmd.encode())
        # 等待并读取一行响应（假设返回以换行结尾）
        response = ser.readline().decode().strip()
        if not response:
            print("未收到响应")
            return None

        # 解析响应：预期格式为 "0,  5.8000E-12" 或 "0\t5.8000E-12"
        parts = response.replace(',', ' ').split()  # 将逗号替换为空格后再按空白分割
        if len(parts) < 2:
            print(f"响应格式异常: {response}")
            return None

        # 第二个元素即为数值字符串
        value_str = parts[1]
        # 转换为浮点数
        value = float(value_str)
        return value

    except serial.SerialException as e:
        print(f"串口错误: {e}")
        return None
    except ValueError as e:
        print(f"数值转换失败: {e}")
        return None
    finally:
        # 确保关闭串口
        if 'ser' in locals() and ser.is_open:
            ser.close()

if __name__ == "__main__":
    print(f"[{timestamp()}] 开始读取数值，每 5 秒一次，按 Ctrl+C 退出...")
    try:
        while True:
            result = read_rpv_value()
            try:
                temperature, pressure = send_command_and_calculate()
            except:
                print(f"[{timestamp()}] 水温压力获取失败")
            if result is not None:
                
                try: 
                    writedata(f"ExpData,location=HFNL,source=MOTIG vacuum={result}")
                    print(f"[{timestamp()}] 真空数据上传成功")
                except:
                    print(f"[{timestamp()}] 真空数据上传失败！！！")
                time.sleep(1)
                try: 
                    writedata(f"ExpData,location=HFNL,source=Coil_Interlock water_temp={temperature},water_pres={pressure}")
                    print(f"[{timestamp()}] 水冷数据上传成功")
                    
                except:
                    print(f"[{timestamp()}] 水冷数据上传失败！！！")
            else:
                print(f"[{timestamp()}] 本次读取失败")
            time.sleep(4)   # 等待 5 秒后继续
    except KeyboardInterrupt:
        print(f"\n[{timestamp()}] 用户中断，程序退出")

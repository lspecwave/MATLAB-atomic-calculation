import socket

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
        print(f"成功连接至PLC {plc_ip}:{plc_port}")
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
        print(f"发送命令: {command_hex}")

        # 接收响应数据（接收缓冲区为1024字节，根据需要调整）
        response = plc_socket.recv(1024)
        if not response:
            print("未接收到响应数据")
            return None, None

        # 将返回的字节数据转换为大写的十六进制字符串
        response_hex = response.hex().upper()
        print(f"接收到的响应: {response_hex}")
    
        # 检查数据长度是否足够，至少需要14个字符（对应7个字节）
        if len(response_hex) < 14:
            print("返回数据长度不足，无法提取指定字段")
            return None, None
        
        # 提取第7-10位和第11-14位
        # 注意：字符串索引从0开始，第7-10位对应索引 [6:10]，
        #       第11-14位对应索引 [10:14]
        field1_hex = response_hex[6:10]
        field2_hex = response_hex[10:14]
        print(f"提取字段1（第7-10位 十六进制）：{field1_hex}")
        print(f"提取字段2（第11-14位 十六进制）：{field2_hex}")

        # 将字段转换为10进制
        value1 = int(field1_hex, 16)
        value2 = int(field2_hex, 16)
        print(f"字段1转换为10进制：{value1}")
        print(f"字段2转换为10进制：{value2}")

        # 根据换算公式计算 Temperature 和 Pressure
        Temperature = 100 * ((value1 - 4000) / 16000)
        Pressure = 2.5 * ((value2 - 4000) / 16000)
        print(f"计算得到: Temperature = {Temperature:.2f}, Pressure = {Pressure:.2f}")
        
        return Temperature, Pressure

    except Exception as e:
        print(f"处理过程中出现错误: {e}")
        return None, None
    finally:
        plc_socket.close()

if __name__ == "__main__":
    # 调用发送命令、读取返回值以及换算的函数
    temperature, pressure = send_command_and_calculate()
    if temperature is not None and pressure is not None:
        print(f"\n最终结果：Temperature = {temperature:.2f}, Pressure = {pressure:.2f}")
    else:
        print("获取Temperature和Pressure失败。")
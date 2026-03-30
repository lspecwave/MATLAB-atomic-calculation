
import influxdb
import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

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




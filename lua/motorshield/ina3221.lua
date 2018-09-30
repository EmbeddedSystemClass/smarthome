local ina3221 = {}

local id  = 0
local CHIP_ADDRESS = 0x40


local SHUNT_VALUE = 0.1 --Shunt resistor value, Ohm


local REG_CONFIG = 0x00
local REG_SHUNTVOLT_BASE = 0x01
local REG_BUSVOLT_BASE = 0x02


local CONFIG_ENABLE_CHAN1 = 0x4000  --Enable Channel 1
local CONFIG_ENABLE_CHAN2 = 0x2000  --Enable Channel 2
local CONFIG_ENABLE_CHAN3 = 0x1000  --Enable Channel 3
	
local CONFIG_AVG2 = 0x0800  --AVG Samples Bit 2 - See table 3 spec
local CONFIG_AVG1 = 0x0400  --AVG Samples Bit 1 - See table 3 spec
local CONFIG_AVG0 = 0x0200  --AVG Samples Bit 0 - See table 3 spec

local CONFIG_VBUS_CT2 = 0x0100  --VBUS bit 2 Conversion time - See table 4 spec
local CONFIG_VBUS_CT1 = 0x0080  --VBUS bit 1 Conversion time - See table 4 spec
local CONFIG_VBUS_CT0 = 0x0040  --VBUS bit 0 Conversion time - See table 4 spec

local CONFIG_VSH_CT2 = 0x0020  --Vshunt bit 2 Conversion time - See table 5 spec
local CONFIG_VSH_CT1 = 0x0010  --Vshunt bit 1 Conversion time - See table 5 spec
local CONFIG_VSH_CT0 = 0x0008  --Vshunt bit 0 Conversion time - See table 5 spec

local CONFIG_MODE_2 = 0x0004  --Operating Mode bit 2 - See table 6 spec
local CONFIG_MODE_1 = 0x0002  --Operating Mode bit 1 - See table 6 spec
local CONFIG_MODE_0 = 0x0001  --Operating Mode bit 0 - See table 6 spec



local function read_reg(dev_addr, reg_addr)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    i2c.stop(id)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    val = struct.unpack('>h', i2c.read(id, 2))
    i2c.stop(id)
    return val
end

local function write_reg(dev_addr, reg_addr, reg_val)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    i2c.stop(id)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    -- c = i2c.write(id, bit.rshift(reg_val, 8))
    -- c = c + i2c.write(id, bit.band(reg_val, 0x00FF))
    c = i2c.write(id, struct.pack('>h', reg_val))
    i2c.stop(id)
    return c
end

function ina3221.init()
    i2c.setup(id, GPIO_SDA, GPIO_SCL, i2c.SLOW)
    config = bit.bor(CONFIG_ENABLE_CHAN1,
        CONFIG_ENABLE_CHAN2,
        CONFIG_ENABLE_CHAN3,
        CONFIG_AVG1,
        CONFIG_VBUS_CT2,
        CONFIG_VSH_CT2,
        CONFIG_MODE_2,
        CONFIG_MODE_1,
        CONFIG_MODE_0)
    return write_reg(CHIP_ADDRESS, REG_CONFIG, config) == 2
end

function ina3221.get_manid()
    return read_reg(CHIP_ADDRESS, 0xFE)
end

function ina3221.get_busvolt_raw(channel)
    if channel < 1 or channel > 3 then return 0 end
    return read_reg(CHIP_ADDRESS, REG_BUSVOLT_BASE + (channel - 1) * 2)
end

function ina3221.get_shuntvolt_raw(channel)
    if channel < 1 or channel > 3 then return 0 end
    return read_reg(CHIP_ADDRESS, REG_SHUNTVOLT_BASE + (channel - 1) * 2)
end

function ina3221.get_voltage_V(channel)
    return ina3221.get_busvolt_raw(channel) * 0.001
end

function ina3221.get_shuntvolt_mV(channel)
    return ina3221.get_shuntvolt_raw(channel) * 0.005
end

function ina3221.get_current_mA(channel)
    return ina3221.get_shuntvolt_mV(channel) / SHUNT_VALUE;
end


return ina3221

import cocotb
from cocotb.triggers import Timer

def adder_model(a, b, cin):
    result = a + b + cin
    return result & 0xF, (result >> 4) & 1

async def driver(dut, a, b, cin):
    dut.a.value = a
    dut.b.value = b
    dut.cin.value = cin

async def monitor(dut):
    return int(dut.sum.value), int(dut.cout.value)

@cocotb.test()
async def main(dut):
    
    print("I am the hierarchical testbench")

    for i in range(14):
        a = i
        b = i+1
        cin = 0 if i<8 else 1
        await driver(dut, a, b, cin)

        await Timer(1, unit="ns")

        expected_sum, expected_cout = adder_model(a, b, cin)
        d_sum, d_cout = await monitor(dut)

        assert int(dut.sum.value) == expected_sum, f"Sum error! ESum={expected_sum} Sum={int(dut.sum.value)}"
        assert int(dut.cout.value) == expected_cout, f"Cout error! ECout={expected_cout} Cout={int(dut.cout.value)}"


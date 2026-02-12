import cocotb 
from cocotb.triggers import Timer

@cocotb.test()
async def basic_test(dut):
    for i in range(14):
        dut.a.value = i
        e_a = i
        dut.b.value = i+1        
        e_b = i+1

        if i < 8:
            dut.cin.value = 0
            e_cin = 0
        else:
            dut.cin.value = 1
            e_cin = 1
        
        await Timer(1, unit='ns')

        result = e_a + e_b + e_cin
        expected_sum = result & 0xF
        expected_cout = (result >> 4) & 1

        assert int(dut.sum.value) == expected_sum, f"Sum error! ESum={expected_sum} Sum={int(dut.sum.value)}"
        assert int(dut.cout.value) == expected_cout, f"Cout error! ECout={expected_cout} Cout={int(dut.cout.value)}"


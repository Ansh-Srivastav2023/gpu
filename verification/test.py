import cocotb  # type: ignore
from cocotb.triggers import Timer, RisingEdge  # type: ignore
from cocotb.clock import Clock  # type: ignore
import logging
import random

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def signed_value(sig, width=32):
    """Convert cocotb signal to signed integer (two's complement)"""
    val = sig.value.to_signed()
    if val & (1 << (width - 1)):
        val -= (1 << width)
    return val


@cocotb.test()
async def gpu_test(dut):
    logger.info("Starting the GPU test...\n")

    clock = Clock(dut.clk, 5, unit="ns")
    cocotb.start_soon(clock.start())

    for num in range(1000):
        logger.info(f"🧪 This is test no. ---> {num + 1}")

        dut.kernel_start.value = 1
        dut.rst.value = 0

        for i in range(12):
            dut.gpu_dmem_top.gpu_dmem.dmem[i].value = random.randint(1, 1000)
            dut.gpu_dmem_top.gpu_dmem.dmem[i + 12].value = random.randint(1, 1000)

        logger.info("Reset the GPU...")
        await Timer(12, unit="ns")

        dut.rst.value = 1
        logger.info("Reset released...")

        logger.info("Waiting for END...")
        while dut.instruction.value.to_unsigned() != 0xC0000000:
            await RisingEdge(dut.clk)

        logger.info("END received...")

        for i in range(12):
            a = signed_value(dut.gpu_dmem_top.gpu_dmem.dmem[i])
            b = signed_value(dut.gpu_dmem_top.gpu_dmem.dmem[i + 12])
            c = signed_value(dut.gpu_dmem_top.gpu_dmem.dmem[i + 24])

            if a//b != c:
                logger.info(
                    f"Test failed {a} / {b} != {c} ❌"
                    )
            else:
                logger.info(
                    f"dmem[{i}] = {a} / dmem[{i+12}] = {b} ---> dmem[{i+24}] = {c}     ✅"
                )

        logger.info("#" * 77)

    logger.info("✅ The test of GPU is complete...")

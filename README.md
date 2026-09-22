# SystemVerilog JPEG-Like Image Decompressor

A hardware-accelerated image decompression system implemented in **SystemVerilog** for the **Altera DE2-115 FPGA**, capable of reconstructing **192×144-pixel images** from a custom JPEG-like `.mic19` compressed format.

The design implements a multi-stage decoding pipeline controlled by an **FSM-based control unit**, with hardware blocks for **Inverse Discrete Cosine Transform (IDCT)**, **chroma upsampling**, and **YUV-to-RGB color conversion**. The reconstructed image is buffered in SRAM and displayed through VGA.

## Overview

The project was designed to explore how computationally intensive image decompression algorithms can be mapped onto FPGA hardware using:

* RTL/SystemVerilog design
* Finite State Machines (FSMs)
* Multi-stage pipelining
* Fixed-point arithmetic
* On-chip SRAM buffering
* UART-based input
* VGA video output
* Simulation and waveform-based verification

The decompression flow converts compressed `.mic19` image data into RGB pixel data that can be displayed on a VGA monitor.

```text
                  .mic19 Compressed Image
                           |
                           v
                    +-------------+
                    | UART Input  |
                    +-------------+
                           |
                           v
                  +------------------+
                  | Bitstream / Data |
                  |     Decoding     |
                  +------------------+
                           |
                           v
                  +------------------+
                  |      IDCT        |
                  |  Decode Stage    |
                  +------------------+
                           |
                           v
                  +------------------+
                  |    Upsampling    |
                  |  Decode Stage    |
                  +------------------+
                           |
                           v
                  +------------------+
                  |   YUV -> RGB     |
                  |  Decode Stage    |
                  +------------------+
                           |
                           v
                  +------------------+
                  | SRAM Frame Buffer|
                  +------------------+
                           |
                           v
                     +-----------+
                     | VGA Output|
                     +-----------+
                           |
                           v
                    192 × 144 Image
```

## Key Features

### 5-Stage Decoding Pipeline

The decompression architecture uses a pipelined hardware datapath to process image data through multiple decoding stages.

Major processing stages include:

1. **Compressed data decoding**
2. **Inverse Discrete Cosine Transform (IDCT)**
3. **Chroma upsampling**
4. **YUV-to-RGB color conversion**
5. **Pixel/frame-buffer output**

Pipeline registers separate processing stages to allow different portions of the image to be processed concurrently.

### FSM-Based Control Logic

A finite state machine coordinates the movement of data throughout the decompression pipeline.

The control logic manages:

* Input data acquisition
* Decode sequencing
* Pipeline synchronization
* SRAM read/write operations
* Pixel processing
* VGA frame-buffer access

This separates control-path logic from the datapath and provides deterministic sequencing of the hardware operations.

### IDCT Hardware

The project implements the **Inverse Discrete Cosine Transform**, which reconstructs spatial-domain pixel information from frequency-domain coefficients.

The IDCT hardware was designed for FPGA execution using hardware-friendly arithmetic and pipelined processing.

### YUV-to-RGB Conversion

Decoded luminance and chrominance components are converted into RGB pixel values before being stored for display.

```text
Y  ─┐
    ├──> YUV-to-RGB Conversion ───> R
U  ─┤                              G
    │                              B
V  ─┘
```

### SRAM Frame Buffer

Reconstructed pixels are stored in SRAM before being read by the VGA controller.

The frame buffer allows the decompression pipeline and VGA display logic to operate independently.

### VGA Output

The final RGB image is reconstructed and displayed through the DE2-115's VGA interface at a resolution of:

**192 × 144 pixels**

## Verification

The design was verified using **SystemVerilog testbenches** and **ModelSim simulation**.

Verification focused on ensuring that each stage of the decompression pipeline produced the expected output.

### Verification Methodology

```text
SystemVerilog Testbench
          |
          v
   Input Test Data
          |
          v
   RTL Decompressor
          |
          v
   Pipeline Outputs
          |
          v
   Reference Model
          |
          v
    Output Comparison
          |
          v
   Waveform Debugging
```

The verification process included:

* RTL simulation in **ModelSim**
* Testbench-driven input generation
* Intermediate pipeline signal inspection
* Waveform debugging
* Comparison against a reference model
* Validation of pixel reconstruction
* Debugging pipeline timing and control sequencing

## Hardware Platform

| Component        | Description               |
| ---------------- | ------------------------- |
| FPGA Board       | Altera DE2-115            |
| HDL              | SystemVerilog             |
| Simulation       | ModelSim                  |
| Image Format     | `.mic19` JPEG-like format |
| Image Resolution | 192 × 144                 |
| Input            | UART                      |
| Frame Buffer     | SRAM                      |
| Display          | VGA                       |


## Design Architecture

The design is divided into two major components:

### Control Path

The control path is implemented using an FSM responsible for coordinating:

* Decoder state transitions
* Data-valid signals
* Pipeline enables
* SRAM control
* Frame-buffer writes
* VGA synchronization

### Datapath

The datapath performs the actual image reconstruction operations:

```text
Compressed Data
      |
      v
+-------------+
|   Decoder   |
+-------------+
      |
      v
+-------------+
|     IDCT    |
+-------------+
      |
      v
+-------------+
|  Upsampling |
+-------------+
      |
      v
+-------------+
|  YUV -> RGB |
+-------------+
      |
      v
+-------------+
|     SRAM    |
+-------------+
      |
      v
+-------------+
| VGA Display |
+-------------+
```

## Engineering Challenges

Several challenges were addressed during development:

### Pipeline Synchronization

Different processing stages require different amounts of computation and latency. Pipeline registers and control signals were used to ensure that data remained synchronized as it propagated through the decoder.

### Hardware Arithmetic

Image-processing operations such as IDCT and color conversion require significant arithmetic computation. The design therefore uses hardware-oriented arithmetic and carefully manages intermediate values and bit widths.

### Control and Datapath Coordination

The FSM must coordinate multiple hardware modules while accounting for pipeline latency, memory operations, and output timing.

### Hardware/Simulation Debugging

ModelSim waveforms were used to trace internal signals and identify issues involving:

* FSM transitions
* Pipeline timing
* Data-valid propagation
* Intermediate pixel values
* SRAM addressing
* Output synchronization

## Technologies

**Hardware Description Language**

* SystemVerilog
* RTL Design
* Finite State Machines
* Sequential and Combinational Logic
* Pipelined Datapaths

**FPGA / Hardware**

* Altera DE2-115
* SRAM
* UART
* VGA

**Verification**

* ModelSim
* SystemVerilog Testbenches
* Waveform Debugging
* Reference Model Comparison

**Image Processing**

* IDCT
* Chroma Upsampling
* YUV-to-RGB Conversion
* JPEG-like Image Decompression

## Results

The completed hardware design reconstructs compressed `.mic19` images into **192×144 RGB images** and outputs the reconstructed frames through the DE2-115 VGA interface.

The implementation demonstrates the ability to translate an image-processing algorithm into a hardware architecture consisting of:

* FSM-controlled RTL
* Pipelined processing stages
* Hardware arithmetic
* Memory buffering
* Peripheral interfaces
* Simulation-based verification

## Skills Demonstrated

* SystemVerilog RTL Design
* FPGA Development
* Digital Design
* Hardware Pipelining
* FSM Design
* Datapath Architecture
* Hardware Verification
* Testbench Development
* ModelSim Debugging
* Waveform Analysis
* SRAM Interface Design
* UART Communication
* VGA Interfaces
* Digital Image Processing
* Fixed-Point Hardware Arithmetic
* Hardware/Software Reference Model Validation

## Future Improvements

Potential improvements include:

* Increasing pipeline throughput
* Optimizing FPGA resource utilization
* Adding additional image resolutions
* Improving memory bandwidth
* Expanding automated verification and coverage
* Adding assertions for pipeline/control verification
* Supporting additional compressed image formats
* Measuring FPGA resource utilization and maximum operating frequency

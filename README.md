# EE107FinalProject
This project investigates digital communications by sending an image over a channel with noise, similar to an actual communication system (e.g. cell phones, HDTV). The system is implemented in Matlab.
## Communication System
We construct a model of a communications system that transmits an image from one place to another, much like digital television (HDTV). 
It is very common in image processing to break up the image into 8 pixel by 8 pixel blocks and take the discrete cosine transform
(DCT) of each block – we will provide more information on the DCT later in the description. The DCT frequency information for each block can then be coded, modulated, and transmitted, as will be explained now.

A typical communications scheme begins at the transmitter. 

The discrete-time signal x at time step n is quantized, meaning for each n, x[n] is rounded to a binary number of finite precision. That is, for any fixed n, x[n] is a real number mathematically, so it has infinite precision. In order to transmit it digitally, we must, for example, round it to the closest integer from 0 to 255 because we can only transmit finite information digitally. 

After quantization, the signal is often coded. In this project, we will not do any coding. 

Modulation is the process of transforming each sample of the signal (typically coded in real world applications) into an analog (continuous time) waveform that is physically transmittable through the communications channel. This is necessary because essentially all signals in nature are fundamentally continuous (pedantic quantum mechanical arguments aside). The channel is the physical medium through which the modulated waveforms travel; for example, the atmosphere, a telephone wire, or a coaxial cable could all carry an electromagnetic wave. As the modulated waveforms travel along the channel, they are distorted according to the frequency response of the channel (we assume that it is an LTI system, in practice this is a good approximation for a variety of mediums).

Noise is also added to the waveforms. Once they reach the end of the channel, called the receiver, one must try to undo all the distortion caused by the channel. Then the waveforms must be detected and demodulated, or mapped from the analog domain into decoded symbols;
in this case, just the 2-D discrete-time signal we started with.
### System Structure

A block diagram of the communications system is shown in the figure below. 
<p align="center">
<![screen shot 2018-08-10 at 7 01 21 pm](https://user-images.githubusercontent.com/26287301/43984643-daec735a-9ccf-11e8-801e-79e1cfe872db.png)>
</p>
The system consists of the following blocks:

• Image pre-processing: This block includes the transformation and quantization of an image. We break the image into 8 by 8 blocks and perform the DCT on each block. Then we quantize the DCT coefficient values (which are continuous) into 256 levels, using 8-bit unsigned binary numbers.

• Conversion to a bit stream: For serial transmission over a channel, we need to convert the transformed and quantized image into a bit stream. To do this, we first group the 8 by 8 discretized DCT blocks into groups of size N (we will pick it later). We then reshape each group into a 1-D bit stream (i.e. a vector) for transmission.

• Modulation: To send digital bits over a physical channel, we need to represent each bit with a waveform, a process called modulation. In this project, we will use binary PAM (Pulse Amplitude Modulation) with pulse shaping filter gT (t). We will study two different pulse shaping filters in order to compare the effect of pulse shaping on the transmission bandwidth and the error performance. Specifically, we will compare between a half-sine pulse, and a square-root raised cosine (SRRC) pulse with details given later in the implementation section.

• Channel: The channel is a filter with a given impulse response that characterizes the transmission medium, such as a copper wire, a cable, or the air. The channel will be modeled as an LTI system with an impulse response h(t). We will provide the specific
impulse response in the implementation section.

• Noise: At the receiving end, noise (such as circuit thermal noise, interference) is added to the received signal. Therefore the received signal may be written as 

.center[r(t) = s(t) * h(t) + n(t) (1)]

where * is the convolution operator, s(t) is the modulated signal and n(t) is the additive noise. Often the noise is assumed to be white.

• Matched filter: The receiver attempts to recover the transmitted signal that has been filtered by the channel and corrupted by additive noise. A block in the receiver that deals with the effect of noise is the received pulse shaping filter, which is matched to the transmit pulse shaping filter as

.center[g_R(t) = g_T (T − t). (2)]

The matched filter is the best receive filter to deal with the effect of white noise as it results in the highest SNR at the sampling point later. Note that at the output of the

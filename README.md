# Digital Communications
This project investigates digital communications by sending an image over a channel with noise, similar to an actual communication system (e.g. cell phones, HDTV). The system is implemented in Matlab.
## Communication System
We construct a model of a communications system that transmits an image from one place to another, much like digital television (HDTV). 
It is very common in image processing to break up the image into 8 pixel by 8 pixel blocks and take the [discrete cosine transform
(DCT)](https://www.mathworks.com/help/images/discrete-cosine-transform.html) of each block – we will provide more information on the DCT later in the description. The DCT frequency information for each block can then be coded, modulated, and transmitted, as will be explained now.

A typical communications scheme begins at the transmitter. 

The discrete-time signal <a href="https://www.codecogs.com/eqnedit.php?latex=x" target="_blank"><img src="https://latex.codecogs.com/gif.latex?x" title="x" /></a> at time step n is quantized, meaning for each <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a>, <a href="https://www.codecogs.com/eqnedit.php?latex=x[n]" target="_blank"><img src="https://latex.codecogs.com/gif.latex?x[n]" title="x[n]" /></a> is rounded to a binary number of finite precision. That is, for any fixed <a href="https://www.codecogs.com/eqnedit.php?latex=n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?n" title="n" /></a>, <a href="https://www.codecogs.com/eqnedit.php?latex=x[n]" target="_blank"><img src="https://latex.codecogs.com/gif.latex?x[n]" title="x[n]" /></a> is a real number mathematically, so it has infinite precision. In order to transmit it digitally, we must, for example, round it to the closest integer from 0 to 255 because we can only transmit finite information digitally. 

After quantization, the signal is often coded. In this project, we will not do any coding. 

Modulation is the process of transforming each sample of the signal (typically coded in real world applications) into an analog (continuous time) waveform that is physically transmittable through the communications channel. This is necessary because essentially all signals in nature are fundamentally continuous (pedantic quantum mechanical arguments aside). The channel is the physical medium through which the modulated waveforms travel; for example, the atmosphere, a telephone wire, or a coaxial cable could all carry an electromagnetic wave. As the modulated waveforms travel along the channel, they are distorted according to the frequency response of the channel (we assume that it is an LTI system, in practice this is a good approximation for a variety of mediums).

Noise is also added to the waveforms. Once they reach the end of the channel, called the receiver, one must try to undo all the distortion caused by the channel. Then the waveforms must be detected and demodulated, or mapped from the analog domain into decoded symbols;
in this case, just the 2-D discrete-time signal we started with.
### System Structure

A block diagram of the communications system is shown in the figure below. 
<p align="center">
  <img src="https://user-images.githubusercontent.com/26287301/43984643-daec735a-9ccf-11e8-801e-79e1cfe872db.png">
</p>

The system consists of the following blocks:

• Image pre-processing: This block includes the transformation and quantization of an image. We break the image into 8 by 8 blocks and perform the DCT on each block (DCT is used to perform data compression in JPEG images and in MPEG coding including MP3 audio compression). Then we quantize the DCT coefficient values (which are continuous) into 256 levels, using 8-bit unsigned binary numbers.

• Conversion to a bit stream: For serial transmission over a channel, we need to convert the transformed and quantized image into a bit stream. To do this, we first group the 8 by 8 discretized DCT blocks into groups of size N (we will pick it later). We then reshape each group into a 1-D bit stream (i.e. a vector) for transmission.

• Modulation: To send digital bits over a physical channel, we need to represent each bit with a waveform, a process called modulation. In this project, we will use binary PAM (Pulse Amplitude Modulation) with pulse shaping filter gT (t). We will study two different pulse shaping filters in order to compare the effect of pulse shaping on the transmission bandwidth and the error performance. Specifically, we will compare between a half-sine pulse, and a square-root raised cosine (SRRC) pulse with details given later in the implementation section.

• Channel: The channel is a filter with a given impulse response that characterizes the transmission medium, such as a copper wire, a cable, or the air. The channel will be modeled as an LTI system with an impulse response h(t). We will provide the specific
impulse response in the implementation section.

• Noise: At the receiving end, noise (such as circuit thermal noise, interference) is added to the received signal. Therefore the received signal may be written as 

<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=r(t)&space;=&space;s(t)&space;\ast&space;h(t)&space;&plus;&space;n(t)\quad&space;(1)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?r(t)&space;=&space;s(t)&space;\ast&space;h(t)&space;&plus;&space;n(t)\quad&space;(1)" title="r(t) = s(t) \ast h(t) + n(t)\quad (1)" /></a>
</p>

where * is the convolution operator, s(t) is the modulated signal and n(t) is the additive noise. Often the noise is assumed to be white.

• Matched filter: The receiver attempts to recover the transmitted signal that has been filtered by the channel and corrupted by additive noise. A block in the receiver that deals with the effect of noise is the received pulse shaping filter, which is matched to the transmit pulse shaping filter as

<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=g_R(t)=g_T(T-t)\quad&space;(2)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?g_R(t)=g_T(T-t)\quad&space;(2)" title="g_R(t)=g_T(T-t)\quad (2)" /></a>
</p>

The matched filter is the best receive filter to deal with the effect of white noise as it results in the highest SNR at the sampling point later. Note that at the output of the matched filter, the overall pulse shape is the combination of the transmit and receive pulse shaping filters. This is the reason for using a SRRC pulse shaping filter at the transmitter, since after combining with the receive matched filter, the overall pulse shape is a raised-cosine pulse.

• Equalization: A block in the receiver that compensates for the effects of the channel is the equalizer, which is another linear filter. In this project, we will study two types of equalization filters: the zero-forcing filter (which is the inverse of the channel), and the MMSE filter (which also takes into account noise power).

• Sampling and Detection: The output signal of the equalizer is then sampled at the optimal points, which are at multiple symbol intervals. Here we need to perform some simple synchronization to determine when the first received symbol begins and when is the optimal sampling time. After sampling, the received signal is detected, meaning it is examined to determine whether a 0 or 1 was initially sent by the transmitter. Here we will use a simple threshold detection method to recover the transmitted bit stream.

• Conversion to an image: This block reshapes the detected bit streams in the original order into the form of an image. This is the reverse step of conversion to a bit stream.

• Image post-processing: The demodulated image is converted back into groups of 8 by 8 DCTs, which are then transformed back to the image domain.


### Image pre-processing

We assume the image is m by n pixels (grayscale, making sure that m and n are both divisible by 8).
We perform a DCT on the image in 8 by 8 blocks using the blkproc function. 

To prepare the transformed image for quantization, we normalize the values keeping the scaling constants for later; they will be needed
in the post-processing step. Now you can quantize the normalized, transformed image using im2uint8. Next, use reshape and permute to convert the scaled image to a 3 dimensional array of dimension 8 by 8 by mn/64 such that at each point in the 3rd dimension, the first
two are one of the 8 by 8 DCT blocks.

### Conversion to a bit stream
We will transmit DCT blocks in groups of size N (a changeable parameter). Given the current group of N blocks, we reshape it into one long column vector and convert each element of this vector into a row with that element’s 8 bits as the row’s 8 entries using de2bi.

### Modulation

We will implement the modulation using two different pulse shaping functions and compare their performance in terms of the transmission bandwidth and the error probability.

The first pulse shaping function is a half-sine wave where the data bits are multiplied by one half period of a sine wave. Specifically, suppose that a bit b has duration T, for the half-sine pulse shaping function, we send the following signal:
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=g_1(t)=\left\{\begin{matrix}&space;\&space;\sin(\frac{\pi}{T}t)\quad&space;b=1\\&space;-\sin(\frac{\pi}{T}t)\quad&space;b=0&space;\end{matrix}\right.&space;\quad&space;0\leq&space;t\leq&space;T" target="_blank"><img src="https://latex.codecogs.com/gif.latex?g_1(t)=\left\{\begin{matrix}&space;\&space;\sin(\frac{\pi}{T}t)\quad&space;b=1\\&space;-\sin(\frac{\pi}{T}t)\quad&space;b=0&space;\end{matrix}\right.&space;\quad&space;0\leq&space;t\leq&space;T" title="g_1(t)=\left\{\begin{matrix} \ \sin(\frac{\pi}{T}t)\quad b=1\\ -\sin(\frac{\pi}{T}t)\quad b=0 \end{matrix}\right. \quad 0\leq t\leq T" /></a>
  </p>

The second wave will be a square-root raised-cosine (SRRC) where we send the follwoing pulse 
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=g_2(t)=\left\{\begin{matrix}&space;\&space;Ax(t)\quad&space;b=1\\&space;-Ax(t)\quad&space;b=0&space;\end{matrix}\right.&space;\quad&space;-KT\leq&space;t\leq&space;KT" target="_blank"><img src="https://latex.codecogs.com/gif.latex?g_2(t)=\left\{\begin{matrix}&space;\&space;Ax(t)\quad&space;b=1\\&space;-Ax(t)\quad&space;b=0&space;\end{matrix}\right.&space;\quad&space;-KT\leq&space;t\leq&space;KT" title="g_2(t)=\left\{\begin{matrix} \ Ax(t)\quad b=1\\ -Ax(t)\quad b=0 \end{matrix}\right. \quad -KT\leq t\leq KT" /></a>
  </p>
where A is a normalization factor that makes the energy in the SRRC pulse the same as the energy in the half-sine pulse, and K is the truncation length that we will discuss below. The impulse response x(t) of this SRRC pulse is given as
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=x(t)=\frac{sin(\pi\frac{t}{T}(1-\alpha))&plus;4\alpha&space;\frac{t}{T}\cos(\pi\frac{t}{T}(1&plus;\alpha))}{\pi\frac{t}{T}(1-(4\alpha\frac{t}{T})^2)}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?x(t)=\frac{sin(\pi\frac{t}{T}(1-\alpha))&plus;4\alpha&space;\frac{t}{T}\cos(\pi\frac{t}{T}(1&plus;\alpha))}{\pi\frac{t}{T}(1-(4\alpha\frac{t}{T})^2)}" title="x(t)=\frac{sin(\pi\frac{t}{T}(1-\alpha))+4\alpha \frac{t}{T}\cos(\pi\frac{t}{T}(1+\alpha))}{\pi\frac{t}{T}(1-(4\alpha\frac{t}{T})^2)}" /></a>
</p>
where <a href="https://www.codecogs.com/eqnedit.php?latex=\alpha" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\alpha" title="\alpha" /></a> is the rolling factor.

At special points where the above denominator is zero, the values of the SRRC impulse response can be computed to be
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=x(t)=\left\{\begin{matrix}1-\alpha&plus;\frac{4\alpha}{\pi}&t=0\\&space;\frac{\alpha}{\sqrt{2}}\left[(1&plus;\frac{2}{\pi})sin(\frac{\pi}{4\alpha})&plus;(1-\frac{2}{\pi})&space;\cos(\frac{\pi}{4\alpha})\right&space;]&t=\pm\frac{T}{4\alpha}&space;\end{matrix}\right." target="_blank"><img src="https://latex.codecogs.com/gif.latex?x(t)=\left\{\begin{matrix}1-\alpha&plus;\frac{4\alpha}{\pi}&t=0\\&space;\frac{\alpha}{\sqrt{2}}\left[(1&plus;\frac{2}{\pi})sin(\frac{\pi}{4\alpha})&plus;(1-\frac{2}{\pi})&space;\cos(\frac{\pi}{4\alpha})\right&space;]&t=\pm\frac{T}{4\alpha}&space;\end{matrix}\right." title="x(t)=\left\{\begin{matrix}1-\alpha+\frac{4\alpha}{\pi}&t=0\\ \frac{\alpha}{\sqrt{2}}\left[(1+\frac{2}{\pi})sin(\frac{\pi}{4\alpha})+(1-\frac{2}{\pi}) \cos(\frac{\pi}{4\alpha})\right ]&t=\pm\frac{T}{4\alpha} \end{matrix}\right." /></a>
  </p>
Technically, the SRRC pulse goes on for an infinite time duration. For practical implementation, we need to truncate it to [−KT,KT] where typically K = 6. In this project, K is defined as a parameter between 2 and 6.

The fact that the pulse is nonzero outside of its own bit duration implies that there will be overlapping of the modulating waveforms for different bits at the transmitter (even before the signal goes through the channel). Note that the SRRC pulse itself does not satisfy the
Nyquist’s criterion since it does not cross zero at multiple bit intervals nT. However, we apply a matched filter at the output and sample at the correct times so that the output of the matched filter will have the raised cosine spectrum which satisfies the Nyquist’s criterion, and hence we will recover the signal without inter-symbol interference at the receiver.

For the half-sine pulse shaping function, define the modulating sine wave <a href="https://www.codecogs.com/eqnedit.php?latex=\sin(\pi&space;\frac{t}{T})\quad&space;0\leq&space;t\leq&space;T" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\sin(\pi&space;\frac{t}{T})\quad&space;0\leq&space;t\leq&space;T" title="\sin(\pi \frac{t}{T})\quad 0\leq t\leq T" /></a> (assuming the bit duration is T = 1); we suggest using 32 samples.

For the SRRC function, select <a href="https://www.codecogs.com/eqnedit.php?latex=\alpha" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\alpha" title="\alpha" /></a> = 0.5 (make it a parameter so you can change it later). Each bit will span a time duration of 2KT. Any two consecutive bits will have their modulated waveform overlapping by 2K − 1 bit durations ((2K − 1)T). The transmit signal will then be the sum of all the overlapping SRRC waves. For each bit duration, we suggest you use the same number of samples (32 samples) as you use for the half-sine wave. Thus the total number of samples for each SRRC pulse will be 2K*32.

The eye diagram is obtained by superimposing the waveforms of subsequent bits on top of each other. The middle part of this eye should now be open. The vertical width of the opening is the voltage margin, and the horizontal width is the timing margin. These play an important role in signal sampling and reconstruction.

### Channel

We iterate over block groups to simulate sending N 8 by 8 DCT blocks at a time. Since we process the signal in discrete-time, assuming that we sample the channel at the same rate as we sample the received signal, which is at the bit intervals nT, we can use the impulse response h[n] = h(nT) of the equivalent discrete-time system. This is an FIR (finite
impulse response) filter with four taps given as
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=h[n]&space;=\delta&space;[n]&space;&plus;\frac{1}{2}\delta&space;[n-&space;1]&space;&plus;\frac{3}{4}\delta&space;[n-&space;2]&space;-\frac{2}{7}\delta&space;[n-&space;3]&space;." target="_blank"><img src="https://latex.codecogs.com/gif.latex?h[n]&space;=\delta&space;[n]&space;&plus;\frac{1}{2}\delta&space;[n-&space;1]&space;&plus;\frac{3}{4}\delta&space;[n-&space;2]&space;-\frac{2}{7}\delta&space;[n-&space;3]&space;." title="h[n] =\delta [n] +\frac{1}{2}\delta [n- 1] +\frac{3}{4}\delta [n- 2] -\frac{2}{7}\delta [n- 3] ." /></a>
  </p>
The three time delayed echoes here might represent attenuated reflections of the signal in the environment (e.g. reflections off buildings, cars, hills, trees in wireless communications). These echoes cause distortion in the received signal since the received waveforms of different bits will overlap in time, leading to ISI.
h[n] is represented as a vector. The four taps will need to be spaced equally so that there is a full bit duration T in between every two consecutive taps. So as there are 32 samples per bit in the modulation part, there should be 31 zeros in between every two consecutive taps. Making the total number of samples a power of 2, speeds up the implementation!

We send the modulated bit stream through the channel. 

### Noise
We apply additive Gaussian random noise with a specific noise power to the output of the channel.

### Matched Filter

The matched filter is designed to match to the transmit pulse shaping filter as in (2). For each
of the two given pulse shaping functions, implement the impulse response of this matched filter in the same way as you construct the pulse shaping function.

### Equalizer
We apply an equalization filter in an attempt to recover the modulated signal as it was before passing through the channel. In this project we will try two different equalizers.

#### Zero-Forcing (ZF) Equalizer
This filter is just the inverse of the channel response. 

#### MMSE Equalizer
If there were no noise and the channel were invertible, the ZF filter would perfectly recover the modulated signal. In practice, however, there is always noise. In addition, we often don’t know the channel response precisely since we can only make noisy measurements of it. It can also change quite suddenly over time (imagine a person holding a cell phone while walking or traveling in a car) and hence the channel measurements need to be updated frequently, making it more noise prone. Hence we consider a different filter that takes both the channel
and the noise into account.

Using detection and estimation theory, it is possible to design filters that simultaneously invert the channel response and try to undo some of the effects of the noise. One popular filter of this type is called the minimum mean square error filter, or MMSE filter, since it
minimizes the mean, or average, of the square of the difference between the transmitted signal and the received signal. The MMSE filter takes the noise into account via the signal-to-noise ratio, or SNR, defined as the ratio of the signal power to the noise power (calculated at the sampling point in the receiver). The signal power is obtained from the pulse shaping
functions introduced above. For the half-sine pulse, its average power is 1/2. For the SRRC pulse, we choose the normalization factor A so that the pulse energy (over its truncated duration) is the same as the half-sine energy, so that the signal power at the sampling point
in the receiver is the same for the two pulse shaping functions. (In fct, in the codes for pulse
shaping and matched filter that we gave you, the pulses are already normalized in energy so you don’t need to worry about further normalization.)
The frequency response of the MMSE equalizer is then given as

<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=Q_{\textrm{MMSE}}(z)=\frac{H^{\ast}(z)}{|H(z)|^2&plus;2\sigma^2}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Q_{\textrm{MMSE}}(z)=\frac{H^{\ast}(z)}{|H(z)|^2&plus;2\sigma^2}" title="Q_{\textrm{MMSE}}(z)=\frac{H^{\ast}(z)}{|H(z)|^2+2\sigma^2}" /></a>
  </p>
where <a href="https://www.codecogs.com/eqnedit.php?latex=\sigma^2" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\sigma^2" title="\sigma^2" /></a> is the noise power.

### Sampling and Detection
In converting from the received waveform to discrete-time, we need to sample the signal. Here we sample at the output of the equalizer at the bit intervals. But before sampling, we determine when the first received bit begins in time and when is the best sampling
instance. The subsequent sampling times are just multiple of the bit intervals from the first
sampling instance. 

Using a simple zero threshold, if the sample is positive, then we say we received a 1, otherwise a 0. From this, construct a matrix of bits with the nth row containing eight entries corresponding to the eight bits of the nth received and detected pixel.

### Conversion to an image
We now convert the detected matrix to a vector of integers with bi2de and use reshape and permute to place the received 8 by 8 DCT blocks into the proper place in the full image.

### Image post-processing
Invert the DCT blocks using blkproc and rescale the resulting image using the inverse of the normalization from the pre-processing stage.

## Effect of the channel
We also try two other channels with the impulse response given below. These are actual wireless channel models used in designing cellular
systems. An outdoor channel is given as
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=\small&space;h_1[n]&space;=&space;0.5ï¿½\delta[n]&space;&plus;&space;\deltaï¿½[n-&space;1]&space;&plus;&space;0.63ï¿½\delta[n-3]&space;&plus;&space;0.25\deltaï¿½[n-8]&space;&plus;&space;0.16ï¿½\delta[n-12]&space;&plus;&space;0.1ï¿½\delta[n-&space;25]" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\small&space;h_1[n]&space;=&space;0.5ï¿½\delta[n]&space;&plus;&space;\deltaï¿½[n-&space;1]&space;&plus;&space;0.63ï¿½\delta[n-3]&space;&plus;&space;0.25\deltaï¿½[n-8]&space;&plus;&space;0.16ï¿½\delta[n-12]&space;&plus;&space;0.1ï¿½\delta[n-&space;25]" title="\small h_1[n] = 0.5ï¿½\delta[n] + \deltaï¿½[n- 1] + 0.63ï¿½\delta[n-3] + 0.25\deltaï¿½[n-8] + 0.16ï¿½\delta[n-12] + 0.1ï¿½\delta[n- 25]" /></a>
</p>
and an indoor channel as
<p align="center">
  <a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;\dpi{200}&space;\tiny&space;h_2[n]&space;=&space;\delta[n]&space;&plus;0.4365\deltaï¿½[n-&space;1]&space;&plus;&space;0.1905ï¿½\delta[n-2]&space;&plus;&space;0.0832\deltaï¿½[n-3]&space;&plus;&space;0.0158\delta[n-5]&space;&plus;&space;0.003ï¿½\delta[n-&space;7]" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\inline&space;\dpi{200}&space;\tiny&space;h_2[n]&space;=&space;\delta[n]&space;&plus;0.4365\deltaï¿½[n-&space;1]&space;&plus;&space;0.1905ï¿½\delta[n-2]&space;&plus;&space;0.0832\deltaï¿½[n-3]&space;&plus;&space;0.0158\delta[n-5]&space;&plus;&space;0.003ï¿½\delta[n-&space;7]" title="\tiny h_2[n] = \delta[n] +0.4365\deltaï¿½[n- 1] + 0.1905ï¿½\delta[n-2] + 0.0832\deltaï¿½[n-3] + 0.0158\delta[n-5] + 0.003ï¿½\delta[n- 7]" /></a>
  </p>

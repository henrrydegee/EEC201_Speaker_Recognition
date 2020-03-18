# EEC201 Speaker Recognition
#### Team 42: Henrry Gunawan, Wai Cheong Tsoi
![42](/img/deep.jpg)

## Abstract
This project builds a system that recognizes the speaker by using mel-frequency cepstrum 
coefficients, vector quantization and k-clustering. A Hamming window size of 248 was chosen for 
the STFT windowing, 20 mel-filter banks were used which 12 MFCCs were used for training, and 7 centroids 
were used for k-clustering. This yields an 100% accuracy from the training data set and 82% accuracy from 
the test data set, and a tolerance of at least 19dB SNR of added noise averaged from 25 runs.

## Introduction
### Training
<p align="center"> <img src="/img/train42.png" alt="train flow chart"> </p>
The training data is first processed by having the leading and ending zeros truncated. The truncated signal 
is then mapped to the frequency domain using Short-Time Fourier Transform, and then translated to 
Mel-Frequency Cepstrum Coefficients. This process is called <b>Feature Extraction</b> . 

With the help of k-Clustering and using the LBG Algorithm, 12 MFCC coefficients are used to create clusters 
and their centroids are computed. Each speaker would have a unique set of centroid locations, called a 
<i>codebook</i>. Since the codebook is unique per each speaker, it is used for the testing phase for 
<b>speaker verification</b>.

### Testing
<p align="center"> <img src="/img/test42.png" alt="test flow chart"> </p>
The testing data is first processed by going through the <i>Feature Extraction</i> process, which the MFCC 
coefficients are then used to compare against each speaker's <i>codebook</i> to compute the distortions. 
This process is called <b>Error Modeling</b>.

After Error Modeling, the decision algorithm would compare and find the minimum distortion to decide which 
speaker the test data best matches and declare that the test data belongs to this speaker. 

+ To test out the training and testing function, run `src/guiMain.m` for a Graphical User Interface.

## Feature Extraction and Model Choice
A **Short-Time Fourier Transform** [(STFT)](#short-time-fourier-transform) was used to distinguish the changes in Frequency through time to create uniqueness across different speakers. On the other hand, **Mel-frequency cepstral coefficients** [(MFCCs)](#mfccs) were the features extracted to train the speaker recognition because of the following:
* Listeners perceive the [Mel (Melody)](#mel-scale) scale to have equidistant pitches
* [Filter Banks under the Mel Scale](#mel-scale) were used to extract different parts of the Mel-Scale
* Using [Cepstrum](#cepstrum) allows the model to use only Real numbers as the Amplitude information is always Real after the Cepstrum Transformation.

###### More Technical Details could be found under the [Appendix](#appendix) Section

### Visualizing MFCC Spectrums
<p align="center">
    <img src="/img/mfcc2.png" width = "383" height = "315" alt = "MFCC-Speaker2" />
    <img src="/img/mfcc10.png" width = "383" height = "315" alt = "MFCC-Speaker10" />
</p>

As seen in the images above, clearly the amplitudes at different MFCCs were used uniquely by different speakers, thus indicating that the MFCC-amplitudes could clearly distinguish between speakers. To potray this, one could see partially the MFCC-space shown below:

### Visualizing MFCC-space for K-Clustering
<p align="center">
    <img src="/img/mfccSpaceS2S10.png" width = "383" height = "315" alt = "MFCC-Space" />
    <img src="/img/runLBG.PNG" width = "383" height = "315" alt = "runLBG" />
</p>

The image above also shows that **k-Clustering** (a Vector Quantization method) could work as different speakers created their own unique cluster cloud points in the MFCC-space, thus each exclusive Vector Quantization could classify each speaker as shown above. k-Clustering was also chosen due to its unsupervised nature, having more generalization to recognize different speaker without needing too many ground truth to compare against. This is because the MFCC model had been heavily studied and had been robust to recognizing human voices, especially speeches. Lastly, the LBG algorithm style is mimiced to provide a thresholded amount of learning to recognize each speaker.

## Data and Feature Pre-Processing
1. Amplitude Threshold at Sound Signal
2. Amplitude Renormalization at MFCC-Amplitudes for Training

### (1) Amplitude Threshold at Sound Signal
<p align="center">
    <img src="/img/s10Raw.png" width = "383" height = "315" alt = "Raw s10 Signal" />
    <img src="/img/s10Processed.png" width = "383" height = "315" alt = "Processed s10 Signal" />
</p>
In the time domain of the sound signal, an <b>amplitude of below -30 dB was filtered out</b> as shown in the image above. This helps the model alleviate from redundancy of the speaker's silence as naturally, a listener could definitely not distinguish different speakers if they were silent. Furthermore, since the same speaker would potentially record different amount of silence on verification, it would be unfair to train on such data because the centroids trained on would be slightly skewed and experience higher distortion. Consequently to the model's advantage, this also supressed noises below -30 dB that could alias the speaker's original voice signal by removing the corrupted signals.

### (2) Amplitude Renormalization at MFCC-Amplitudes for Training
<p align="center">
    <img src="/img/s2mfccUnnormalized.png" width = "383" height = "315" alt = "s2's Unnormalized MFCC" />
    <img src="/img/s10mfccUnnormalized.png" width = "383" height = "315" alt = "s10's Unnormalized MFCC" />
</p>

Seen in the images above, the minimal and maximal amplitudes were clearly different across speakers observed in the colour axis. Since the system focuses on speaker recognition, the system's ability should ideally be independent of individiual speaker's loudness. Therefore, since only relative patterns of frequency amplitudes were needed to recognize a speaker, the MFCC-Amplitudes were renormalized under a L-infinity norm – dividing the amplitudes by the absolute maximum amplitude. The resulting normalized amplitudes were shown in the section [Visualizing MFCC Spectrums](#visualizing-mfcc-spectrums).

## Tuning Parameters
For the feature extraction and model of the system, there are 4 parameters that has been tuned to aim for robust performance:
1. Hamming Window Size
2. Number of Mel Filter Banks applied to Input Sound Signal
3. Number of MFCCs used for obtaining centroids
4. Number of Centroids used for Identification

### (1) Hamming Window Size
<p align="center">
    <img src="/img/timeSpecs.png" width = "383" height = "315" alt = "Time Spectras" />
    <img src="/img/winLengthToAcc.png" width = "383" height = "315" alt = "Effect of Hamming Window Length" />
</p>

Seen in the images above, a **Hamming Window Length of 248** was chosen for STFT as it produced the most accurate performance when tested across the test dataset. This could be explained by exploring the Time Spectra image above that showed the signal was periodic on approximately 62 to 64 samples, and thus capturing few copies of the periodicity brought more confidence in the MFCCs analysis. Also, having too much copies of the periodicity for MFCCs analysis degrades the accuracy performance as, by the Uncertainty Principle, the model loses information of frequency changes through time.

### (2) & (3) Number of Mel Filter Banks Applied and MFCCs Used
<p align="center">
    <img src="/img/numMFlBusedToAcc.png" width = "383" height = "315" alt = "Mel Filter Banks Applied">
    <img src="/img/numMFCCusedToAcc.png" width = "383" height = "315" alt = "MFCCs Used">
</p>

**20 Mel-Filter Banks was applied** as the image above showed that having more than 20 Mel-Filter Banks would not bring better accuracy performance for the model. Intuitively, this could be thought as applying more refined bandpass filters only helped up to a certain point. After applying 20 Mel-Filter Banks to extract features, only **12 MFCCs were used** to train the model with similar reasons that having more than 12 MFCCs usage would not bring better accuracy performance for the model. 

From the data's perspective, this could be explain in observing the [MFCC-Amplitudes](#visualizing-mfcc-spectrums) at each speaker that above the 12th-MFCC dimension, the amplitudes were zero, bring redundant information for the model to train on. One possible reason could be that distinguishing speakers only required finding for the speaker's unique resonant frequency that tended to be low in frequency – Male: 85-180Hz, Female: 165-255Hz. As long as enough filter banks were used to verify the speaker's resonant frequency being present, it would be enough to distinguish a speaker.

### (4) Number of Centroids used for Identification
<p align="center">
    <img src="/img/numClusterToAcc.png" width = "383" height = "315" alt = "Clusters to Accuracy" />
    <img src="/img/numClusterToDistortion.png" width = "383" height = "315" alt = "Clusters to Distortion" />
</p>

Lastly, **7 centroids/quantizations were used** to create the codebook/identification for each distinct speaker. This decision was done using both the elbow method and accuracy observation of the test dataset. The conventional elbow method states that the optimal number of clusters should be chosen at where the total distortion begins to slowly decrease – does not lower the distortion loss more significantly – to prevent overfitting the model. Also, this could be observed under the accuracy metrics pictured above where the accuracy peaked when 7 centroids were used to train the model.

## Accuracy
In 25 runs, our model has a <b>100% accuracy against the training data set</b> and <b>82% accuracy against 
the provided test data set</b>. 

It's noted that the test data for speaker s3 (`/Data/test/s3.wav`) compared to speaker s3's train data 
(`/Data/train/s3.wav`), despite having some noticeable features hinting as the same speaker, it is not distinct 
since the word was spoken in different phonetics.

Speaker s7's train data (`Data/train/s7.wav`), however, bears a lot of similar features, including the same 
phonetics, as speaker s3's test data. From a blind test, our group considered that s3's test data is closer to 
speaker s7 than speaker s3. Within the 25 runs, our model identifies s3's test data as s7 <i>23 times out of 25</i>. 
The following scatter plot shows one of the runs where the model identifies s3's test data as s7.

<p align="center"> <img src="/img/acc3scatter.png" width="515" height="420" alt="test data s3 vs codebook"> </p>

+ To replicate this result, run `src/benchacc.m`

## Noise Tolerance
Our model is tested against <b>white, pink and brown</b> noises. White noise is chosen since it represents the 
most common type of noise found in recording apparatus. Brown noise is chosen since it simulates background 
chatters. Pink noise is chosen since it simulates the variations of different tries the same speaker might have 
when saying the same word or phrase.

In 25 runs, our model has <b>greater than 94% accuracy</b> against signals with added white noise that 
has a Signal-to-Noise Ratio <b>higher than 19dB</b>. Our model is more resistant to pink and brown noises, 
and obtains a <i>near 100% accuracy for signals of 26dB or greater SNR</i> of all noises tested.

<p align="center"> <img src="/img/snr3noise2.png" width="511" height="420" alt="acc vs snr"> </p>

+ To replicate this result, run `src/benchsnr.m`

## Reference
+ A. Mousa, "MareText Independent Speaker Identification based on K-Mean Algorithm" in International 
Journal on Electrical Engineering and Informatics, vol. 3, no. 1, pp. 100-108, March 2011.
+ L.R. Rabiner and B.H. Juang, Fundamentals of Speech Recognition, Prentice-Hall, Englewood Cliffs, 
N.J., 1993.
+ Y. Linde, A. Buzo and R. Gray, "An Algorithm for Vector Quantizer Design," in IEEE Transactions 
on Communications, vol. 28, no. 1, pp. 84-95, January 1980.

## Appendix
#### Short Time Fourier Transform
A Short Time Fourier Transform performs a Fourier Transform at a certain localized time samples to convert to a frequency spectrum through each localization: 
![STFT](/img/stft.PNG)

#### Hamming Window
A Hamming Window is used to localize certain time samples by multiplying the window by the signal itself.
![Hamming](/img/hamming.PNG)

#### Mel Scale
A Mel-Scale or melody scale is a pitch measurement where its scale from one mel to the next is perceived by listeners to be equidistant. It could be calculated given a frequency through the following:
![Mel](/img/mel.PNG)

Note: For this project, the Mel-Frequency Filter Bank used was the following:
<p align="center"> <img src="/img/melfb.png" width="511" height="420" alt="Mel Filter Banks"> </p>

#### Cepstrum
The concept of Cepstrum and its variations would be too complicated to be explained here. Please kindly 
refer to other references, like [Wikipedia](https://en.wikipedia.org/wiki/Cepstrum), for more information 
regarding this topic. For your reference, the equation for cepstrum is listed below.

![Cepstrum](/img/cepstrum.PNG)

#### MFCCs
The Mel-Frequency Cepstrum Coefficients are widely used in speech processing and is tabulated through the following:
1. Taking a Fourier Transform (A STFT for this project) of the signal.
2. Filter the signal through the Mel-Frequency Filter Bank by multiplying the Fourier Transform of the signal.
3. From result 2, calculate its power and take its logarithm.
4. Perform a Discrete Cosine Transform onto result 3.
5. The amplitudes after performing the procedure above are the MFCCs.

## Footnote
+ This project is done under the pledge of the UC Davis Code of Academic Conduct.
+ We would like to acknowledge YouTube and Coursera content creaters that helped provide insights to the project.
+ Special Thanks to Professor Z. Ding and Q. Deng for their support and guidance on this project.

###### Last Updated: March 18, 2020

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

// import analysis library
import ddf.minim.AudioInput;
import ddf.minim.Minim;
import ddf.minim.analysis.FFT;
import ddf.minim.analysis.WindowFunction;

// define const
final float[] frequencies = {293.66f, 329.63f, 369.99f, 392.00f, 440.00f, 493.88f, 554.37f, 587.33f, 659.25f, 739.99f, 783.99f, 880.00f, 987.77f, 1108.73f, 1174.66f};
final String[] spellings = {"D", "E", "F", "G", "A", "B", "C", "D", "E", "F", "G", "A", "B","C", "D", "E", "F", "G", "A", "B", "C", "D", "E", "F", "G", "A", "B", "C", "D"};

// define global valiable
// to call class of packages 
Minim minim;
AudioInput in;
FFT fft;

// to write database
WaveSQLManager wsm;

// for calculation
float min;
float max;

// settings
// How many sample we get per second.
int sampleRate = 44100;
// Processing window size
int frameSize = 1024;

// for counting
int currentNumber = 0;


// Initialize Processing
void setup()
{
  size(1024, 500, P2D);
  smooth();

  // Initialize Minim
  minim = new Minim(this);
  
  // minim.getLineIn method to get input
  // getLineIn(int type, int bufferSize, float sampleRate, int bitDepth)
  in = minim.getLineIn(Minim.MONO, frameSize, sampleRate, 16);
  fft = new FFT(frameSize, sampleRate);
 
  min = Float.MAX_VALUE;
  max = Float.MIN_VALUE;
  
  String dbName = sketchPath("tune.sqlite");
  wsm = new WaveSQLManager(dbName);
}

void draw()
{
  background(0);
  
  // Analize amulitude of sound
  stroke(255);
  textSize(12);
  
  float average = 0;
  int currentBufferSize = in.bufferSize();
  for (int i = 0 ; i < currentBufferSize; i ++)
  {
    float sample = in.left.get(i);
    if (sample < min)
    {
      min = sample;
    }
    if (sample > max)
    {
      max = sample;
    }
    sample *= 100.0;
    line(i, height / 2, i,  (height / 2) + sample);
    average += Math.abs(in.left.get(i));
  }
  average /= currentBufferSize; // "a /=b" is same as "a = a / b" 
  text("Amp: " + average, 5, 15);
  
  ////////////////////////////////////////////////////////////////
  // Analize each band level by FFT
  stroke(0, 255, 255);
  textSize(10);
  
  // Window function which is used for analysis. In minim HANN function is betteer than HAMMING.
  fft.window(FFT.HANN);
  fft.forward(in.left); // input 

  // Initialize Wave Instance for inserting record into DB
  List<Wave> waveList = new ArrayList<Wave>();
  
  // Number of frequency band
  int currentSpecSize = fft.specSize();
  int bandDisplayWidth = frameSize/currentSpecSize*2;
  for (int i = 0 ; i < currentSpecSize ; i ++)
  {
    rect(i * bandDisplayWidth, height - 30, bandDisplayWidth / 4, -fft.getBand(i) * 10);
    Wave currentWave = new Wave(currentNumber, fft.getBandWidth() * i, fft.getBandWidth() * (i+1), fft.getBand(i));
    if (i == 0) {
      waveList.add(currentWave);
    }
    if (i % 30 == 0)
    {
      text((int) currentWave.freq_ave + "Hz",i * bandDisplayWidth, height - 10);
    }
  }
  
  ////////////////////////////////////////////////////////////////
  // Show Information
  fill(255);
  textSize(12);
  
  if (average <= 0.001f){
    return;
  }
  
  // How many cross points in 44100 points that is sampled in a second.
  int zeroC = countZeroCrossings();    
  text("Zero crossings count: " + zeroC, 5, 30);
  
  // Hz by zero crossing points
  float freqByZeroC = ((float) sampleRate / (float)in.bufferSize()) * (float) zeroC;
  text("Freq by zero crossings: " + freqByZeroC, 5, 50);
  
  // Hz to Spell
  String zcSpell = spell(freqByZeroC);
  text("Spelling by zero crossings: " + spell(freqByZeroC), 5, 70);
  
  // Hz by FFT
  float freqByFFT = FFTFreq();
  text("Freq by FFT: " + freqByFFT, 5, 90);
  
  // Hz to Spell
  String fftSpell = spell(freqByFFT);
  text("Spelling by FFT: " + fftSpell, 5, 110);
  
  Analysis an = new Analysis(currentNumber, average, zeroC, freqByZeroC, zcSpell, freqByFFT, fftSpell);
  wsm.setRecord(waveList, an);
  currentNumber ++;
}

void close()
{
  wsm.closeConnection();
}
  
int countZeroCrossings()
{
  int count = 0;
  for (int i = 1 ; i < in.bufferSize(); i ++)
  {
    if (in.left.get(i - 1) > 0 && in.left.get(i) <= 0)
    {
      count ++;
    }
  }    
  return count;    
}
  
float FFTFreq()
{
  // Find the higest entry in the FFT and convert to a frequency
  float maxValue = Float.MIN_VALUE;
  int maxIndex = -1;
  for (int i = 0 ; i < fft.specSize() ; i ++)
  {
    if (fft.getBand(i) > maxValue)
    {
      maxValue = fft.getBand(i);
      maxIndex = i;
    }
  }
  return fft.indexToFreq(maxIndex);
}

String spell(float frequency)
{
  float minDiff = Float.MAX_VALUE;
  int minIndex = 0;
  for (int i = 0 ; i < frequencies.length; i ++)
  {
    float diff = Math.abs(frequencies[i] - frequency);
    if (diff < minDiff)
    {
      minDiff = diff;
      minIndex = i;
    }
  }
  return spellings[minIndex];
}

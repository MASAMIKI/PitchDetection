
class Analysis
{
  public int number;
  public float amp;
  public float zeroCrossings;
  public float freqByZeroCrossings;
  public String spellingByZeroCrossings;
  public float freqByFft;
  public String spellingByFft;

  public Analysis(int n, float a, float z, float fz, String sz, float ff, String sf) {
    this.number = n;
    this.amp = a;
    this.zeroCrossings = z;
    this.freqByZeroCrossings = fz;
    this.spellingByZeroCrossings = sz;
    this.freqByFft = ff;
    this.spellingByFft = sf;
  }
}

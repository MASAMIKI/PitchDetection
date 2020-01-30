
class Wave
{
  public int number;
  public float freq_min;
  public float freq_max;
  public float freq_ave;
  public float level;

  public Wave(int n, float mn, float mx, float l) {
    this.number = n;
    this.freq_min = mn;
    this.freq_max = mx;
    this.freq_ave = (mx + mn)/2;
    this.level = l;
  }
}

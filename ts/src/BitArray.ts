/**
 * NOTE
 * Placeholder for more generic bit array which is available in both Crystal and
 * C++.  This one is going to be for 10 bits only.
 */
import _ from 'lodash';

export default class BitArray {
  private bits: number = 0;

  constructor(initial: boolean = false) {
    this.bits = initial ? 0x3ff : 0;
  }

  clone() {
    const ba = new BitArray();
    ba.bits = this.bits;
    return ba;
  }

  public get(n: number) {
    return Boolean((this.bits >> n) & 1);
  }

  public set(n: number, value: boolean) {
    if (value) {
      this.bits |= 1 << n;
    } else {
      this.bits &= ~(1 << n);
    }
  }

  public toString() {
    return _.padStart(this.bits.toString(2), 10, '0');
  }
}

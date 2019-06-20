import * as A from './A';

export default class B {
  public someFunction = () => {
    const a = new A.SomeOtherClass();
    console.log('a called ', a);
  }
}

let assert = require('assert');

describe('Array', function () {
  describe('#indexOf(3)', function () {
    it('should return index of 2 when the value is present', function () {
      assert.equal([1,2,3,4,5].indexOf(3), 2);
    });
  });
});


describe('Some boolean', function () {
  describe('another description', function () {
    it('should return index of 4 when the value is present', function () {
      assert.equal([1,2,3,4,5].indexOf(5), 4);
      // throw {"err": "custom error"}
    });

    // let arrInput = [5,3,31,12,2];
    let arrInput = [1,2,3,4,5,6];
    let arrSortedOutput = [1,2,3,4,5,6];
    it('should return true if an array is already sorted', function () {
      assert.deepStrictEqual(arrInput, arrSortedOutput);
    });

  });
});

describe('Array', function () {
  describe('#indexOf()', function () {
    // pending test below
    it('should return -1 when the value is not present');
  });
});
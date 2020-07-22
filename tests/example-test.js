let assert = require('assert');

function getMax(array) {
    let maxVal = Number.MIN_SAFE_INTEGER;
    for(let i=0; i < array.length;i++){
        if( array[i] > maxVal ) maxVal = array[i];
    }
    return maxVal;
}

function reverseArray(array){
    let res = [];
    for(let i=array.length-1; i >= 0;i--){
        res.push(array[i]);
    }
    return res;
}

function ascSort(a,b){ return a-b;}

function descSort(a,b){ return b-a;}

function someStringFunc(string){
    if(string == "test") return "blah";
    return "foo bar";
}

function compareSomething(someBool, someValue, targetVal){
  if(someBool && someValue > targetVal) return true;
  return false;
}

describe('Array', function () {
  describe('sort ASC', function () {
    it('should return the array in sorted ASCENDING order', function () {
      assert.deepStrictEqual([1,2,4,5,3,53].sort(ascSort), [1,2,3,4,5,53]);
    });
  });
});

describe('Array', function () {
  describe('sort DESC', function () {
    it('should return the array in sorted DESCENDING order', function () {
      assert.deepStrictEqual([1,2,4,5,3,53].sort(descSort), [53,5,4,3,2,1]);
    });
  });
});

describe('Array', function () {
  describe('reverseArray()', function () {
    it('should return the array in reverse order', function () {
      assert.deepStrictEqual(reverseArray([1,2,4,5,3,53]), [53,3,5,4,2,1]);
    });
  });
});

describe('Array', function () {
  describe('getMax()', function () {
    it('should return the max value of an array', function () {
      assert.equal(getMax([1,2,4,5,3,53]), 53);
    });
  });
});

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

describe('DELAYED suite', function () {

    it('DELAYED should return index of 2 when the value is present', function () {
        assert.equal([1,2,3,4,5].indexOf(3), 2);
    });
});

describe('String', function () {
  describe('someStringFunc()', function () {
    it('should return the string "blah"', function () {
      assert.equal(someStringFunc("test"),"blah");
    });
  });
});


describe('Boolean', function () {
  describe('compareSomething()', function () {
    it('should return false if the first param is false, regardless of the second param', function () {
      assert.equal(compareSomething(false, 5, 10), false);
      assert.equal(compareSomething(false, 12, 10), false);
      assert.equal(compareSomething(false, 10, 10), false);
    });

    it('should return true if the first param is true and the second param is larger than the last param', function () {
      assert.equal(compareSomething(true, 5, 10), false);
      assert.equal(compareSomething(true, 12, 10), true);
    });
  });
});
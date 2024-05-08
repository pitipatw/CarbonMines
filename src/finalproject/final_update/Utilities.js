function stddev(arr) {
  let avg = arr.reduce((acc, c) => acc + c, 0) / arr.length;
  let variance = arr.reduce((acc, c) => acc + (c - avg) ** 2, 0) / arr.length;
  return sqrt(variance);
}


function mean(arr) {
    let avg = arr.reduce((acc, c) => acc + c, 0) / arr.length;
    return avg
  }

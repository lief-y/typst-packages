#let binom-dist(k, n, p, cumulative: true) = {
  let result = 0
  if cumulative {
    for i in range(0, k) {
      result = result + calc.binom(n, i)*calc.pow(p, i)*calc.pow(1 - p, n - i)
    } 
  } else {
    result = calc.binom(n, k)*calc.pow(p, k)*calc.pow(1 - p, n - k)
  }
  return result
}

#let norm-s-dist(x, cumulative: true) = {
  let pi = calc.pi
  if not cumulative {
    // Probability Density Function (PDF)
    return (1.0 / calc.sqrt(2.0 * pi)) * calc.exp(-0.5 * calc.pow(x, 2))
  } else {
    // Cumulative Distribution Function (CDF) Approximation
    let p = 0.2316419
    let b1 = 0.319381530
    let b2 = -0.356563782
    let b3 = 1.781477937
    let b4 = -1.821255978
    let b5 = 1.330274429
    
    let abs-x = calc.abs(x)
    let t = 1.0 / (1.0 + p * abs-x)
    let pdf = (1.0 / calc.sqrt(2.0 * pi)) * calc.exp(-0.5 * calc.pow(x, 2))
    
    let poly = t * (b1 + t * (b2 + t * (b3 + t * (b4 + t * b5))))
    let cdf = 1.0 - pdf * poly
    
    if x < 0 { return 1.0 - cdf } else { return cdf }
  }
}

#let norm-dist(x, mu, sigma, cumulative: true) = {
  let z = (x - mu) / sigma
  return norm-s-dist(z, cumulative: cumulative)
}

#let norm-s-inv(p) = {
  if p <= 0.0 or p >= 1.0 { panic("Probability must be between 0 and 1 exclusive") }

  // Coefficients for the central region (0.02425 < p < 0.97575)
  let a1 = -39.69683028665376
  let a2 = 220.9460984245205
  let a3 = -275.9285104469687
  let a4 = 138.3577518672690
  let a5 = -30.66479806614716
  let a6 = 2.506628277459239

  let b1 = -54.47609879822406
  let b2 = 161.5858368580409
  let b3 = -155.6989798598866
  let b4 = 66.80131188771972
  let b5 = -13.28068155288572

  // Coefficients for the extreme tail regions (p < 0.02425 or p > 0.97575)
  let c1 = -0.007784894002430293
  let c2 = -0.3223964580411365
  let c3 = -2.400758277161838
  let c4 = -2.549732539343734
  let c5 = 4.374664141464968
  let c6 = 2.938163982698783

  let d1 = 0.007784695709041462
  let d2 = 0.3224671290700398
  let d3 = 2.445134137142996
  let d4 = 3.754408661907416

  // Define breakpoints for the algorithm regions
  let p-low = 0.02425
  let p-high = 1.0 - p-low

  if p < p-low {
    // Lower tail calculation
    let q = calc.sqrt(-2.0 * calc.ln(p))
    let num = (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6)
    let den = ((((d1 * q + d2) * q + d3) * q + d4) * q + 1.0)
    return num / den
    
  } else if p <= p-high {
    // Central region calculation
    let q = p - 0.5
    let r = q * q
    let num = (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q
    let den = ((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1.0
    return num / den
    
  } else {
    // Upper tail calculation
    let q = calc.sqrt(-2.0 * calc.ln(1.0 - p))
    let num = (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6)
    let den = ((((d1 * q + d2) * q + d3) * q + d4) * q + 1.0)
    return -num / den
  }
}

#let norm-inv(p, mu, sigma) = {
  let z = norm-s-inv(p)
  return mu + z * sigma
}

#let t-dist(x, df, cumulative: true) = {
  let n = calc.round(df)
  if n < 1 { panic("Degrees of freedom must be >= 1") }
  
  if not cumulative {
    // PDF calculation using Lanczos approximation for log-gamma
    let ln-gamma(z) = {
      let c = (76.18009172947146, -86.50532032941677, 24.01409824083091, -1.231739572450155, 0.001208650973866179, -0.000005395239384953)
      let sum = 1.000000000190015
      let current-z = z
      for i in range(0, 6) {
        current-z = current-z + 1.0
        sum = sum + c.at(i) / current-z
      }
      let tmp = z + 5.5
      tmp = tmp - (z + 0.5) * calc.ln(tmp)
      return -tmp + calc.ln(2.5066282746310005 * sum / z)
    }
    
    let num-ln = ln-gamma((n + 1.0) / 2.0)
    let den-ln = ln-gamma(n / 2.0)
    let coef = calc.exp(num-ln - den-ln) / calc.sqrt(n * calc.pi)
    let base = 1.0 + (x * x) / n
    let power = -(n + 1.0) / 2.0
    return coef * calc.pow(base, power)
    
  } else {
    // CDF calculation using exact expansions for integer df
    let theta = calc.atan(x / calc.sqrt(n))
    let rad-theta = theta.rad()
    let sin-theta = calc.sin(theta)
    let cos-theta = calc.cos(theta)
    
    if n == 1 { return 0.5 + rad-theta / calc.pi }
    
    let is-even = calc.rem(int(n), 2) == 0
    let k = int(n / 2)
    
    if is-even {
      let sum = 1.0
      let term = 1.0
      if k > 1 {
        for j in range(1, k) {
          term = term * calc.pow(cos-theta, 2) * (2.0 * j - 1.0) / (2.0 * j)
          sum = sum + term
        }
      }
      return 0.5 + 0.5 * sin-theta * sum
    } else {
      let sum = 1.0
      let term = 1.0
      if k > 0 {
        for j in range(1, k) {
          term = term * calc.pow(cos-theta, 2) * (2.0 * j) / (2.0 * j + 1.0)
          sum = sum + term
        }
      }
      return 0.5 + (rad-theta + sin-theta * cos-theta * sum) / calc.pi
    }
  }
}

#let t-inv(p, df) = {
  if p <= 0.0 or p >= 1.0 { panic("Probability must be between 0 and 1 exclusive") }
  let n = calc.round(df)
  
  if n == 1 { return calc.tan((p - 0.5) * calc.pi * 1rad) }
  if n == 2 { return (2.0 * p - 1.0) / calc.sqrt(2.0 * p * (1.0 - p)) }
  
  // Base guess via Cornish-Fisher Expansion using the HIGH PRECISION Normal Inverse
  let z = norm-s-inv(p)
  let z2 = calc.pow(z, 2)
  let z3 = calc.pow(z, 3)
  let z5 = calc.pow(z, 5)
  let z7 = calc.pow(z, 7)
  
  let term1 = (z3 + z) / (4.0 * n)
  let term2 = (5.0 * z5 + 16.0 * z3 + 3.0 * z) / (96.0 * calc.pow(n, 2))
  let term3 = (3.0 * z7 + 19.0 * z5 + 17.0 * z3 - 15.0 * z) / (384.0 * calc.pow(n, 3))
  
  let x = z + term1 + term2 + term3
  
  // Newton-Raphson method with tightened tolerance and more iterations
  for i in range(0, 50) {
    let cdf-val = t-dist(x, n, cumulative: true)
    let pdf-val = t-dist(x, n, cumulative: false)
    
    // Safety check against absolute zero float division at extreme tails
    if pdf-val < 1e-250 { break } 
    
    let diff = (cdf-val - p) / pdf-val
    x = x - diff
    
    // Break early if maximum 64-bit float precision is achieved
    if calc.abs(diff) < 1e-14 { break }
  }
  
  return x
}

#let mean(data) = {
  if data.len() == 0 { panic("Array cannot be empty") }
  return data.sum() / float(data.len())
}

#let median(data) = {
  let n = data.len()
  if n == 0 { panic("Array cannot be empty") }
  
  let sorted = data.sorted()
  
  if calc.rem(n, 2) != 0 {
    // Odd number of elements: return the exact middle
    return sorted.at(int(n / 2))
  } else {
    // Even number of elements: average the two middle values
    let mid1 = sorted.at(int(n / 2) - 1)
    let mid2 = sorted.at(int(n / 2))
    return (mid1 + mid2) / 2.0
  }
}

#let mode(data) = {
  if data.len() == 0 { panic("Array cannot be empty") }
  
  // Find unique values and count their occurrences
  let unique = data.dedup()
  let counts = unique.map(u => data.filter(x => x == u).len())
  let max-count = calc.max(..counts)
  
  // Zip the values with their counts, filter by the max count, and extract the values
  return unique.zip(counts).filter(p => p.at(1) == max-count).map(p => p.at(0))
}

#let quartile-exc(data, quart) = {
  if quart != 1 and quart != 2 and quart != 3 {
    panic("Quartile must be 1, 2, or 3")
  }
  
  let n = data.len()
  if n == 0 { panic("Array cannot be empty") }
  
  let sorted = data.sorted()
  
  // Excel's exclusive quartile position formula
  let pos = (quart / 4.0) * (n + 1)
  
  // Replicate Excel's #NUM! error for bounds that fall outside the array
  if pos < 1.0 or pos > float(n) {
    panic("Quartile out of bounds for QUARTILE.EXC (dataset too small)")
  }
  
  let base-idx = int(calc.floor(pos)) - 1 // Convert to Typst's 0-based indexing
  let fraction = pos - calc.floor(pos)
  
  // If it hits exactly on an index, return the value
  if fraction == 0.0 {
    return sorted.at(base-idx)
  } else {
    // Otherwise, interpolate between the upper and lower bounds
    let lower = float(sorted.at(base-idx))
    let upper = float(sorted.at(base-idx + 1))
    return lower + fraction * (upper - lower)
  }
}

#let stdev-p(data) = {
  let n = data.len()
  if n == 0 { panic("STDEV.P requires at least one data point") }
  
  // Calculate the population mean (mu)
  let mu = float(data.sum()) / n
  
  // Calculate the sum of squared deviations
  let sq-diffs = data.map(x => calc.pow(float(x) - mu, 2))
  
  // Divide by N and take the square root
  return calc.sqrt(sq-diffs.sum() / float(n))
}

#let stdev-s(data) = {
  let n = data.len()
  if n <= 1 { panic("STDEV.S requires at least two data points to avoid division by zero") }
  
  // Calculate the sample mean (x-bar)
  let x-bar = float(data.sum()) / n
  
  // Calculate the sum of squared deviations
  let sq-diffs = data.map(x => calc.pow(float(x) - x-bar, 2))
  
  // Divide by (N - 1) and take the square root
  return calc.sqrt(sq-diffs.sum() / float(n - 1))
}
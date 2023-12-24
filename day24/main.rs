#![feature(trait_alias)]

use std::io::Read;

trait Num<T> = std::ops::Add<T, Output = T>
  + std::ops::Sub<T, Output = T>
  + std::ops::Mul<T, Output = T>
  + std::ops::Neg<Output = T>
  + Copy
  + Clone
  + std::fmt::Debug;

#[derive(Debug, Copy, Clone)]
struct Vec3<T> {
  x: T,
  y: T,
  z: T,
}

impl<T: Num<T>> Vec3<T> {
  fn new(x: T, y: T, z: T) -> Self { Self { x, y, z } }

  fn dot(&self, other: Self) -> T {
    self.x * other.x + self.y * other.y + self.z * other.z
  }

  fn cross(&self, other: Self) -> Self {
    Self::new(
      self.y * other.z - self.z * other.y,
      self.z * other.x - self.x * other.z,
      self.x * other.y - self.y * other.x,
    )
  }
}

impl Vec3<i128> {
  fn fcast(&self) -> Vec3<f64> {
    Vec3::<f64>::new(self.x as f64, self.y as f64, self.z as f64)
  }
}

impl<T: Num<T>> std::ops::Add for Vec3<T> {
  type Output = Self;

  fn add(self, other: Self) -> Self {
    Self::new(self.x + other.x, self.y + other.y, self.z + other.z)
  }
}

impl<T: Num<T>> std::ops::Sub for Vec3<T> {
  type Output = Self;

  fn sub(self, other: Self) -> Self {
    Self::new(self.x - other.x, self.y - other.y, self.z - other.z)
  }
}

impl<T: Num<T>> std::ops::Neg for Vec3<T> {
  type Output = Self;

  fn neg(self) -> Self {
    Self::new(-self.x, -self.y, -self.z)
  }
}

#[derive(Debug, Copy, Clone)]
struct Ray<T> {
  origin: Vec3<T>,
  dir: Vec3<T>,
}

impl<T: Num<T>> Ray<T> {
  fn new(origin: Vec3<T>, direction: Vec3<T>) -> Self { Self { origin, dir: direction } }

  fn adjust(&self, delta_dir: Vec3<T>) -> Self {
    Self::new(self.origin, self.dir + delta_dir)
  }

  fn eval(&self, t: T) -> Vec3<T> {
    Vec3::<T>::new(
      self.origin.x + t * self.dir.x,
      self.origin.y + t * self.dir.y,
      self.origin.z + t * self.dir.z,
    )
  }
}

// Type alias for results
type AocResult<T> = std::result::Result<T, Box<dyn std::error::Error>>;

fn parse_line(s: &str) -> AocResult<Ray<i128>> {
  let parse_coords = |s: &str| {
    let parts = s
      .split(", ")
      .map(|x| x.trim().parse::<i128>().unwrap())
      .collect::<Vec<_>>();
    Ok(Vec3 { x: parts[0], y: parts[1], z: parts[2] })
  };

  let parts = s
    .split(" @ ")
    .map(|x| parse_coords(x))
    .collect::<AocResult<Vec<_>>>()?;
  Ok(Ray::new(parts[0], parts[1]))
}

const EPS: f64 = 1e-8;

fn solve2(
  a11: f64,
  a12: f64,
  a21: f64,
  a22: f64,
  b1: f64,
  b2: f64,
) -> Option<(f64, f64)> {
  let det = a11 * a22 - a12 * a21;
  if det.abs() < EPS {
    return None;
  }

  let s = (b1 * a22 - b2 * a12) / det;
  let t = (b2 * a11 - b1 * a21) / det;
  Some((s, t))
}

fn ll_intersect(l1: &Ray<f64>, l2: &Ray<f64>) -> (Option<Vec3<f64>>, f64, f64) {
  let dx = l1.origin.x - l2.origin.x;
  let dy = l1.origin.y - l2.origin.y;
  if let Some((s, t)) = solve2(l2.dir.x, -l1.dir.x, l2.dir.y, -l1.dir.y, dx, dy) {
    let ipt = l1.eval(t);
    return (Some(ipt), t, s);
  } else {
    return (None, 0.0, 0.0);
  }
}

fn solve2_int(
  a11: i128,
  a12: i128,
  a21: i128,
  a22: i128,
  b1: i128,
  b2: i128,
) -> Option<(i128, i128)> {
  let det = a11 * a22 - a12 * a21;
  if det.abs() == 0 {
    return None;
  }

  assert!((b1 * a22 - b2 * a12) % det == 0);
  assert!((b2 * a11 - b1 * a21) % det == 0);

  let s = (b1 * a22 - b2 * a12) / det;
  let t = (b2 * a11 - b1 * a21) / det;
  Some((s, t))
}

fn ll_intersect_int(l1: &Ray<i128>, l2: &Ray<i128>) -> (Option<Vec3<i128>>, i128, i128) {
  let dx = l1.origin.x - l2.origin.x;
  let dy = l1.origin.y - l2.origin.y;
  if let Some((s, t)) = solve2_int(l2.dir.x, -l1.dir.x, l2.dir.y, -l1.dir.y, dx, dy) {
    return (Some(l1.eval(t)), t, s);
  } else {
    return (None, 0, 0);
  }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
  let mut s = String::new();
  std::io::stdin().read_to_string(&mut s)?;

  let int_lines = s
    .lines()
    .map(|x| parse_line(x))
    .collect::<AocResult<Vec<Ray<i128>>>>()?;

  let lines = int_lines
    .iter()
    .map(|r| Ray::<f64>::new(r.origin.fcast(), r.dir.fcast()))
    .collect::<Vec<_>>();

  let l = 200000000000000.0;
  let r = 400000000000000.0;
  let mut res = 0;

  for i in 0..lines.len() {
    for j in i + 1..lines.len() {
      if let (Some(ipt), t, s) = ll_intersect(&lines[i], &lines[j]) {
        if t >= 0.0 && s >= 0.0 && l <= ipt.x && ipt.x <= r && l <= ipt.y && ipt.y <= r {
          res += 1;
        }
      }
    }
  }

  println!("Part 1: {}", res);

  fn test_triple(delta: Vec3<i128>, lines: &Vec<Ray<i128>>) -> bool {
    // p_i + t_i * v_i  =  start + t_i * delta
    // p_i + t_i * (v_i - delta) = start
    // p_i + t_i * (v_i - delta) = p_j + t_j * (v_j - delta) = start
    //
    // v_i - delta,  v_j - delta  and  p_i - p_j  must be coplanar,
    // i.e. triple product must be zero.
    for i in 0..lines.len() {
      for j in i + 1..lines.len() {
        let l1 = &lines[i];
        let l2 = &lines[j];

        let co = (l1.origin - l2.origin).dot((l1.dir - delta).cross(l2.dir - delta));
        if co.abs() > 0 {
          return false;
        }
      }
    }
    true
  }

  let n = 300;
  let res = (|| {
    for dir_x in -n..n {
      for dir_y in -n..n {
        for dir_z in -n..n {
          let delta = Vec3::<i128>::new(dir_x, dir_y, dir_z);
          if test_triple(delta, &int_lines) {
            return Some(delta);
          }
        }
      }
    }
    None
  })();

  if let Some(delta) = res {
    for i in 0..int_lines.len() {
      for j in i + 1..int_lines.len() {
        let l1 = int_lines[i].adjust(-delta);
        let l2 = int_lines[j].adjust(-delta);

        if let (Some(ipt), _t, _s) = ll_intersect_int(&l1, &l2) {
          println!("Part 2: {:?}", ipt.x + ipt.y + ipt.z);
          return Ok(());
        }
      }
    }
  }
  Ok(())
}

fn binarySearch(array: &[i32], find: i32) -> i32 {
    let mut start: usize = 0;
    let mut end = array.len() - 1;
    let mut midle = 0;

    while start <= end {
        midle = start + (end - start) / 2;
        if array[midle] == find {
            return midle as i32;
        } else if array[midle] < find {
            start = midle + 1;
        } else {
            end = midle - 1;
        }
    }
    return -1;
}

#[cfg(test)]
mod tests {
    use crate::chapter2::exercise3_5;

    #[test]
    fn it_works() {
        let arr = [1, 2, 3, 4, 5];
        println!("{}", exercise3_5::binarySearch(&arr, 999));
    }
}
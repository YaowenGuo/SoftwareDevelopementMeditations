fn insertSort(arr: &mut [i32]) {
    for i in 1 .. arr.len() {
        println!("!{}", i);
        insert(arr, i, arr[i]);
    }
}

// TODO change to binary insert.
fn insert(arr: &mut [i32], end: usize, insert: i32) {
    let mut i = end;
    while i > 0 {
        if arr[i - 1] > insert {
            arr[i] = arr[i - 1];
        } else {
            arr[i] = insert;
            break;
        }
        i -= 1;
    }
    if i == 0 {
        arr[i] = insert;
    }
}

#[cfg(test)]
mod tests {
    use crate::chapter2::exercise3_6;

    #[test]
    fn test() {
        let mut arr = [2, 3, - 5, 32, 0, 4, 99, 2];
        exercise3_6::insertSort(&mut arr);
        println!("{:?}", arr)
    }
}

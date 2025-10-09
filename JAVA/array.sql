------------------------------------------------------------------------------------------------------
# Revserse element using array:-
main call :-
int [] arr = new int[] {1,2,3,4,5,6,7};
        reverserArray(arr,7,3);
        System.out.println(Arrays.toString(arr));
        //outout {4,5,6,7,1,2,3}


// using reverse method
    private static void reverserArray(int [] arr, int a, int b){
        // a = size of array and b = partion of array
        rotateArray(arr,0, b-1);
        rotateArray(arr, b, a-1);
        rotateArray(arr,0, a-1);
    }

    private static void rotateArray(int [] arr, int i, int j) {
        while (i <= j) {
            int temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
            i++;
            j--;

        }
    }

------------------------------------------------------------------------------------------------------    
# Search an element in a sorted Rotated Array:-

System.out.println(serach(new int[] {5,6,7,8,9,10,1,2,3}, 0, 8, 10))
output :- 5

private static int serach(int arr[], int l, int r, int key){
        int pivot = getPivot(arr, l, r);
        int e = bs(arr,l,pivot,key);
        if(e == -1)
            e = bs(arr, pivot + 1, r, key);
        return e;
    }

    private static int getPivot(int [] arr, int l, int r){
        while (l <= r){
            int mid = (l + r )/2;
            if(arr[mid] > arr[mid + 1])
                return mid;
            else if (arr[mid] < arr[mid -1])
                return mid - 1;
            else if (arr[mid] > arr[l])
                l= mid + 1;
            else
                r = mid - 1;
        }
        return -1;
    }

    private static int bs(int [] arr, int l, int r, int key){
        while (l <= r){
            int mid = (l + r)/2 ;
            if(arr[mid] == key)
                return mid;
            else if (arr[mid] < key)
                l = mid + 1;
            else
                r = mid - 1;
        }
        return -1;
        }

---------------------------------------------------------------------------------------------------
# Factorial (Recurtion)
// Non Tail Recurtion :-
    private static int factorialFunction(int n){
        if(n == 0)
            return 1;
        return n * factorialFunction(n - 1);
    }

//Tial Recurtion :-
    private static int factorialTail(int n){
        return helper(n,1);
    }

    private static int helper(int n, int ans){
        if(n == 0)
            return ans;
        return helper(n -1, ans * n);
    }        
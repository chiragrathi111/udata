//binaryToDecimalSt
    private static int getBinaryToDecimalSt(String bin){
        int length = bin.length();
        int res = 0;
        int pow = 0;
        for (int i = length - 1; i >=0; i--){
            Character c = bin.charAt(i);
            int lastDigit = Character.getNumericValue(c);
            res += Math.pow(2, pow) * lastDigit;
            pow ++;
        }
        return res;
    }

    //decimalTo Binary
    private static String getDecimalToBinarySt(int n){
        if(n == 0)
            return "0";
        String result = "";
        while(n>0){
            int rem = n % 2;
            n = n/2;
            result += rem;
        }
        return new StringBuilder(result).reverse().toString();
    }

    //binaryTo Decimal
    private static void getBinaryToDecimal(int n){
        int decimal = 0;
        int power = 0;
        while(n > 0){
            int lastDigit = n % 10;
            decimal += lastDigit * Math.pow(2, power);
            power++;
            n = n / 10;
        }
        System.out.println(decimal);
    }

    //decimalTobinary
    private static void getDecimalToBinary(int n){
        int [] binearyNum = new int[1000];
        int i =0;
        while(n > 0){
            binearyNum[i] = n % 2;
            n = n / 2;
            i++;
        }

        for(int j = i - 1; j>=0; j--){
            System.out.println(binearyNum[j]);
        }
    }


//Bitwise Left & Right
  5 = 101
  Symbol(<<)Bitwise Left shift = 1010 (mean 0 addon)  (Binary count = 10) one short cut if you have any no on Bitwise left shift *2 like(5*2 = 10)
  Symbol(>>)Bitwise Right Shift = 010 (mean last value remove and 0 added on right side)  (Binary count = 2)  one short cut if you have any no on Bitwise right Shift /2 like(5/2 = 2)


  Question n power x  = n & n-1 == 0 

----------------------------------------------------------------------------------------------------------------
  //Divisible & NonDivisible Sums Difference
    private static int getDivisibleNonDivisibleSumsDifference(int n, int m){
       int num1 = 0,num2 = 0;
       for(int i = 1; i<=n; i++){
           if(i % m != 0)
               num1 += i;
           else
               num2 += i;
       }
       return num1 - num2;
    }

    //Divisible & NonDivisible Sums
    private static int getDivisibleNonDivisibleSumsNew(int n, int m){
      int x = n/m;
      int num2 = m * (x * (x+1))/2;
      int num1 = n * (n+1)/2 - num2;
      return num1 - num2;
    }
----------------------------------------------------------------------------------------------------------------
    //get Count pair whose sum less then target
    private static int getCountPair(List<Integer> nums, int target){
        int res = 0;
        for(int i=0; i< nums.size(); i++){
            for(int j= i+1; j< nums.size(); j++){
                if(nums.get(i) + nums.get(j) < target)
                    res++;
            }
        }
        return res;
    }

     List<Integer> a = new ArrayList<>(Arrays.asList(-1,1,2,3,1)); //mutable
        //List<Integer> a = Arrays.asList(-1,1,2,3,1);
//        List<Integer> a = new ArrayList<>(List.of(-1,1,2,3,1)); //immutable
        System.out.println(getCountPair(a,2));



        //get Count pair whose sum less then target using sorted array
    private static int getCountPairSorted(List<Integer> nums, int target){
        int res = 0;
        nums.sort((a,b) ->a-b); //sort on assednding order
        int left = 0;
        int right = nums.size() - 1;
        while(left < right){
            if(nums.get(left) + nums.get(right) < target){
                res += right - left;
                left++;
            }else{
                right--;
            }
        }
        return res;
    }

----------------------------------------------------------------------------------------------------------------

    //getRemove Duplicate element on Sorted
    private static int getRemoveDuplicate(int [] nums){
        int unique = 1;
        for(int i = 1; i< nums.length; i++){
            if(nums[i] != nums[i-1]){
                nums[unique] = nums[i];
                unique++;
            }
            }
        return unique;
    }

    ////getRemove Duplicate element on Sorted but array is not sorted
    private static int getRemoveDuplicateNotSorted(int [] nums){
        int unique = 1;
        Arrays.sort(nums);
        for(int i = 1; i< nums.length; i++){
            if(nums[i] != nums[i-1]){
                nums[unique] = nums[i];
                unique++;
            }
        }
        return unique;
    }

int [] arr = new int[] {7,8,8,1,1,2,2,3,3,4,4,5,5,6};
        System.out.println(getRemoveDuplicateNotSorted(arr));
----------------------------------------------------------------------------------------------------------------     
//How to Custom sort String
    private static String getSortString(String order, String s){
        StringBuilder sb = new StringBuilder();
        Set<Character> set = new HashSet();
        int [] c = new int[26];
        for(char i : order.toCharArray()){
            set.add(i);
        }
        for (char j : s.toCharArray()){
            if(set.contains(j))
                c[j - 'a']++;
        }
        for(char k : order.toCharArray()){
            int l = c[k - 'a'];
            while (l-- > 0){
                sb.append(k);
            }
            }
        for(char m : s.toCharArray()){
            if(!set.contains(m))
                sb.append(m);
        }
        return sb.toString();
    }






----------------------------------------------------------------------------------------------------------------





   ----------------------------------------------------------------------------------------------------------------
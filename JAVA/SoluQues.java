static void sortDutchFlag(){
	int[] arr = {1,2,0,2,1,0,0,2,1,0,2};
	int low = 0, mid = 0, high = arr.length - 1;
	while(mid <= high){
		if (arr[mid] == 0 ) {
			int tem = arr[low];
			arr[low] = arr[mid];
			arr[mid] = tem;
			low++;
			mid++;
		}else if(arr[mid] == 1){
			mid++;
		}else{
			int tem = arr[mid];
			arr[mid] = arr[high];
			arr[high] = tem;
			high--;
		}
	}
	for (int;num ;arr ) {
		System.out.print(num + " ");
	}
}

// Minimum Jump

static int minJump(){
	int[] arr = {1,2,0,2,1,0,0,2,1,0,2};

	if (arr.length <= 1) {
		return 0;
	}
	if (arr[0] = 0) {
		return -1;
	}

	int jumps = 0;
	int current = 0;
	int fast = 0;

	for (int i = 0;i < arr.length ;i++ ) {
		fast = Math.max(fast, i + arr[i]);

		if (i == current) {
			jumps++;
			current = fast;
		}

		if (current >= arr.length - 1) {
			break;
		}
	}
	return jumps;
} 

// Trapping Rain Water

static int trappingRainWater(){
	int[] arr = {3,0,2,0,4};
	int n = arr.length;

	int[] leftMax = new int[n];
	leftMax[0] = arr[0];
	for (int i = 1;i < n ;i++ ) {
		leftMax[i] = Math.max(leftMax[i-1], arr[i]);
	}

	int[] rightMax = new int [n];
	rightMax[n-1] = arr[n-1];
	for(int i = n-2; i >= 0; i--){
		rightMax[i] = Math.max(rightMax[i+1], arr[i]);
	}

	int totalWater = 0;
	for (int i = 0; i < n ; i++) {
		int water = Math.min(leftMax[i],rightMax[i]) - arr[i];

		if (water > 0) {
			totalWater += water;
		}
	}
	return totalWater;
}

////  P47:  Longest common prefix

static String longestCommonPrefix(){
	String[] arr = {"ram","rama","ra"};
	String prefix = arr[0];

	for(int i =1; i<arr.length; i++){
		while(!arr.startWith(prefix)){
			prefix = prefix.substring(0, prefix.length -1);
			if (prefix.isEmpty()) {
				return "";
			}
		}
	}
	return prefix;
}

//// 54

static String longestSubStringWithoutRepeatingchar(String a){
	HashMap<Character,Integer> lastseen = new HashMap<>();
	int start =0;
	int maxStart = 0;
	int maxLength = 0;

	for(int end = 0; end <a.length; end ++){
		char c = a.charAt(end);

		if (lastseen.containsKey(c) && lastseen.get(c) >= start) {
			start = lastseen.get(c) +1;
		}

		lastseen.put(c,end);

		int currentLen = end - start +1;
		if (currentLen > maxLength) {
			maxLength = currentLen;
			maxStart = start;
		}
	}
	return a.substring(maxStart, maxStart + maxLength);
}

class TicTacToe{
	char[][] board = new char[3][3];

	TicTacToe(){
		for(int i = 0; i< 3; i++){
			for (int j = 0;j < 3 ;j++ ) {
				board[i][j] = ' ';
			}
		}
	}

	void printBoard(){
		System.out.println(" 1 2 3");
		for(int i = 0; i < 3 ; i ++){
			System.out.print(i+1 + " ");
			for(int j = 0; j < 3 ; j ++){
				System.out.print(board[i][j]);
				if (j < 2) {
					System.out.print("|");
				}
			}
			System.out.println();
			if (i < 2) {
				System.out.println("-------");
			}
		}
	}

	boolean makeMove(int row, int col, char player){
		if (row < 0 || row > 2 || col < 0 || col > 2) {
			System.out.println("Invalid Move");
			return false;
		}

		if (board[i][j] != ' ') {
			System.out.println("Already Taken !");
			return false;
		}

		board[row][col] = player;
		return true;
	}

	boolean checkWin(char player){
		// row check
		for(int i = 0; i < 3 ; i ++){
			if (board[i][0] == player && board[i][1] == player && board[i][2] == player) {
				return true;
			}
		}

		// column check
		for(int j =0; j < 3; j++){
			if (board[0][j] == player && board[1][j] == player && board[2][j] == player) {
				return true;
			}
		}

		if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
			return true;
		}

		if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
			return true;
		}
		return false;
	}

	boolean checkDraw(){
		for(int i =0 ; i < 3; i++){
			for(int j = 0; j < 3; j ++){
				if (board[i][j] == ' ') {
					return false;
				}
			}
		}
		return true;
	}

	void playGame(){
		Scanner sc = new Scanner(System.in);
		char player = 'X';

		while (true) {
			printBoard();

			System.out.println("Player " + player + " enter the row and col value (0-2)");

			int row = sc.nextInt();
			int col = sc.nextInt();

			if (!makeMove(row,col,player)) {
				continue;
			}

			if (checkWin(current)) {
				printBoard();
				System.out.println("Player " + current + " Win!");
				break;
			}

			if (checkDraw()) {
				printBoard();
				System.out.println("DRAW!")
				break;
			}

			// Switch player

			current = (current == 'X' ? 'O' : 'X');
		}
	}
}
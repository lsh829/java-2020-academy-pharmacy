import java.util.Scanner;

public class App {
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		Customer customer = new Customer();
		Pharmacist pharmacist = new Pharmacist();
		try {
			int ch;
			while (true) {
				do {
					System.out.print("1.사용자 2.약사 3.종료 > ");
					ch = sc.nextInt();
				} while (ch < 1 || ch > 3);
				if (ch == 3) {
					break;
				}
				switch (ch) {
				case 1:
					// 손님
					customer.customer();
					break;
				case 2:
					// 약사
					pharmacist.pharmacistManage();
					break;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			sc.close();
		}
	}
}

@isTest
private class AssetTabTest {
	
	@isTest static void test_method_one() {
		PageReference Page = new PageReference('/apex/AssetTab');
		test.setcurrentpage(Page);
		AssetTabExt ate = new AssetTabExt();
		ate.gototab();


	}
	
}
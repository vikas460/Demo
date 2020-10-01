public class AssetTabExt {




	public PageReference gototab(){
		string u = Url.getSalesforceBaseUrl().toExternalForm();
		system.debug(logginglevel.info, '*****u='+u);
		Pagereference MyPage = new Pagereference(u+'/02i');
		MyPage.setRedirect(true);
		return MyPage;
	}

}
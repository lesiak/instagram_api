import 'package:instagram_api/instagram_api.dart';

main() async {
  InstagramScrapper igScrapper = InstagramScrapper(["_ulalla"]);
  await igScrapper.authenticateWithLogin();
  //print("Logged in as aguest");
  //await igScrapper.scrape();
  igScrapper.close();
}

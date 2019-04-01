import 'package:instagram_api/instagram_api.dart';

main() async {
  var awesome = Awesome();
  print('awesome: ${awesome.isAwesome}');
  
  InstagramScrapper igScrapper = InstagramScrapper(["_ulalla"]);
  await igScrapper.authenticate_as_guest();
  print("Logged in as aguest");
  await igScrapper.scrape();
  igScrapper.close();
}

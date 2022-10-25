import 'package:flutter/material.dart';
import 'package:profilecenter/providers/favorite_provider.dart';
import 'package:profilecenter/modules/favoriteCandidat/favorite_candidat_card.dart';
import 'package:profilecenter/utils/helpers/get_translate_string.dart';
import 'package:profilecenter/widgets/circular_progress.dart';
import 'package:profilecenter/widgets/error_screen.dart';
import 'package:provider/provider.dart';

class FavoriteCandidat extends StatefulWidget {
  static const routeName = '/favoriteCandidat';

  @override
  _FavoriteCandidatState createState() => _FavoriteCandidatState();
}

class _FavoriteCandidatState extends State<FavoriteCandidat> {
  @override
  void initState() {
    super.initState();
    fetchFavorite();
  }

  void fetchFavorite() async {
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.fetchFavorite(context);
  }

  @override
  Widget build(BuildContext context) {
    FavoriteProvider favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslate(context, "FAVORITE_CANDIDATS")),
      ),
      body: favoriteProvider.isLoading
          ? Center(child: circularProgress)
          : favoriteProvider.isError
              ? ErrorScreen()
              : favoriteProvider.favorites.length == 0
                  ? Center(
                      child: Text(getTranslate(context, "NO_DATA")),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: favoriteProvider.favorites.length,
                                  itemBuilder: (context, index) {
                                    return FavoriteCandidatCard(
                                        favoriteProvider.favorites[index]);
                                  }),
                            ],
                          )),
                    ),
    );
  }
}

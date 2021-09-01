import 'package:flutter/material.dart';

import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/search/search_delegate.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Peliculas'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: MovieSearchDelegate()),
          ) 
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // Tarjetas principales
            CardSwiper(movies: moviesProvider.onDisplayMovies),

            // Slider peliculas
            MovieSlider(
              movies: moviesProvider.popularMovies, // Populares 
              title: 'Populares', // opcional
              onNextPage: () => moviesProvider.getPopularMovies(),
            ),

          ],
        )
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';

class MovieSlider extends StatefulWidget {
  
  final List<Movie> movies;
  final String? title; 
  final Function onNextPage;
  
  const MovieSlider({
    Key? key,
    required this.movies,
    this.title,
    required this.onNextPage
  }) : super(key: key);

  @override
  _MovieSliderState createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {

  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      
      final ScrollPosition scrollPosition = scrollController.position;

      if (scrollPosition.pixels >= scrollPosition.maxScrollExtent - 500) {
        widget.onNextPage();
      }
      
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (this.widget.movies.length == 0) {
      return Container(
        width: double.infinity,
        height: 260,
        child: Center(
          child: CircularProgressIndicator(),
        )
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          
          // TODO: Si no hay titulo no debe mostrar el Widget
          if (this.widget.title != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(this.widget.title!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length,
              itemBuilder: (_, int index) => _MoviePoster(widget.movies[index], '${widget.title}-${index}-${widget.movies[index].id}')
            ),
          )
        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {

  // TODO:
  final Movie movie;
  final String heroId;

  const _MoviePoster(this.movie, this.heroId);

  @override
  Widget build(BuildContext context) {

    movie.heroId = heroId;

    return Container(
      width: 130,
      height: 190,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, 'details', arguments: movie),
            child: Hero(
              tag: movie.heroId!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  image: NetworkImage(movie.getPosterImage()),
                  placeholder: AssetImage('assets/no-image.jpg'),
                  fit: BoxFit.cover,
                  width: 130,
                  height: 190,
                ),
              ),
            ),
          ),

          SizedBox(height: 5),

          Text(
            movie.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),      
    );
  }
}
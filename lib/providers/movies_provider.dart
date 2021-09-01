import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {

  String _apiKey   = '1531f25843954979979c1262ee98aa72';
  String _baseUrl  = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies   = [];

  Map<int, List<Cast>> movieCast = {};
  
  int _popularPage = 0;


  final debouncer = new Debouncer(
    duration: Duration(milliseconds: 500), 
  );

  final StreamController<List<Movie>> _suggestionsStreamController = new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => this._suggestionsStreamController.stream;


  MoviesProvider() {
    print('MoviesProvider inicializado');
    
    this.getOnDisplayMovies();
    this.getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async{
    final Uri url = Uri.https(_baseUrl, endpoint, {
      'api_key'  : _apiKey,
      'language' : _language,
      'page'     : '$page'
    });

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    

    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    
    onDisplayMovies = nowPlayingResponse.results;
    
    // Encargado de actualizar el estado de todos los widgets involucrados.
    notifyListeners();
  }

  getPopularMovies() async {
    
    _popularPage++;
    
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    
    popularMovies = [ ...popularMovies, ...popularResponse.results ];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {

    if(movieCast.containsKey(movieId)) return movieCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    movieCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    
    final Uri url = Uri.https(_baseUrl, '/3/search/movie', {
      'api_key'  : _apiKey,
      'language' : _language,
      'query'    : query
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      // print('tenemos valor a buscar: $value');
      final result = await this.searchMovies(value);
      this._suggestionsStreamController.add(result);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  } 
  
}
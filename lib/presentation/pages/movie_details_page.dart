import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:moviemaster/presentation/blocs/movie_details_bloc/movie_details_bloc.dart';
import 'package:moviemaster/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:moviemaster/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:moviemaster/presentation/blocs/theme_bloc/theme_bloc.dart';
import 'package:moviemaster/presentation/widgets/movie_card.dart';
import 'package:moviemaster/domain/entities/movie_details_entity.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<MovieDetailsBloc>().add(LoadMovieDetails(widget.movieId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openTrailer(String videoKey) async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoKey');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  Widget _buildTrailerCard(VideoEntity video, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openTrailer(video.key),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: video.youtubeThumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(Icons.error,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (video.official)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ОФІЦІЙНИЙ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openTrailer(video.key),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Дивитись трейлер'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab(MovieDetailsEntity movie, BuildContext context) {
    final youtubeVideos =
    movie.videos.where((video) => video.site == 'YouTube').toList();

    if (youtubeVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Трейлери відсутні',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: youtubeVideos.length,
      itemBuilder: (context, index) =>
          _buildTrailerCard(youtubeVideos[index], context),
    );
  }

  Widget _buildBackdrop(MovieDetailsEntity movie, BuildContext context) {
    return Stack(
      children: [
        movie.backdropPath.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: movie.fullBackdropPath,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Icon(Icons.error,
                color: Theme.of(context).colorScheme.error),
          ),
        )
            : Container(color: Theme.of(context).colorScheme.surfaceVariant),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(MovieDetailsEntity movie, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Опис',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
            ),
            child: Text(
              movie.overview,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastTab(MovieDetailsEntity movie, BuildContext context) {
    if (movie.cast.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Акторів не знайдено',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: movie.cast.length,
      itemBuilder: (context, index) {
        final actor = movie.cast[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: actor.profilePath != null
                      ? CachedNetworkImage(
                    imageUrl: actor.fullProfilePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(Icons.person,
                          size: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                    ),
                  )
                      : Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(Icons.person,
                        size: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actor.character,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(MovieDetailsEntity movie, BuildContext context) {
    if (movie.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.reviews,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Відгуків немає',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movie.reviews.length,
      itemBuilder: (context, index) {
        final review = movie.reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(Icons.person,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.author,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (review.createdAt != null)
                            Text(
                              _dateFormat.format(review.createdAt!),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (review.rating > 0)
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 16),
                            const SizedBox(width: 4),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.content.length > 200
                      ? '${review.content.substring(0, 200)}...'
                      : review.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (review.content.length > 200)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                          child: Icon(Icons.person,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.author,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              if (review.createdAt != null)
                                                Text(
                                                  _dateFormat.format(review.createdAt!),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          review.content,
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(
                                            'Закрити',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Читати повністю',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimilarMoviesTab(MovieDetailsEntity movie, BuildContext context) {
    if (movie.similarMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Схожих фільмів не знайдено',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: movie.similarMovies.length,
      itemBuilder: (context, index) {
        final similarMovie = movie.similarMovies[index];
        return MovieCard(
          movie: similarMovie,
          onTap: () {
            context.pushReplacement('/movie/${similarMovie.id}');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
          builder: (context, state) {
            if (state is MovieDetailsLoading) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }

            if (state is MovieDetailsError) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error,
                          size: 64, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context
                            .read<MovieDetailsBloc>()
                            .add(LoadMovieDetails(widget.movieId)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text('Спробувати знову'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is MovieDetailsLoaded) {
              final movie = state.movieDetails;

              return Scaffold(
                body: DefaultTabController(
                  length: 5,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          expandedHeight: 300,
                          floating: false,
                          pinned: true,
                          flexibleSpace: _buildBackdrop(movie, context),
                          leading: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          actions: [
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                if (authState is! Authenticated) {
                                  return Container();
                                }

                                return BlocBuilder<FavoritesBloc, FavoritesState>(
                                  builder: (context, favoritesState) {
                                    bool isFavorite = false;

                                    if (favoritesState is FavoritesLoaded) {
                                      isFavorite = favoritesState.favoriteMovies
                                          .any((fav) => fav.id == movie.id);
                                    }

                                    return IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (authState is Authenticated) {
                                          context.read<FavoritesBloc>().add(
                                            ToggleFavoriteEvent(
                                              userId: authState.user.id,
                                              movieId: movie.id,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              color: Theme.of(context).colorScheme.surface,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'movie-${movie.id}',
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Text(
                                        movie.title,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // Рейтинг
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.white, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              movie.voteAverage.toStringAsFixed(1),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Рік випуску
                                      if (movie.releaseDate != null &&
                                          movie.releaseDate!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                            Theme.of(context).colorScheme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            movie.releaseDate!.substring(0, 4),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                      // Тривалість
                                      if (movie.runtime > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color:
                                            Theme.of(context).colorScheme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${movie.runtime ~/ 60}г ${movie.runtime % 60}хв',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  if (movie.tagline.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      '"${movie.tagline}"',
                                      style: TextStyle(
                                        color:
                                        Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],

                                  if (movie.genres.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: movie.genres
                                          .map((genre) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          genre,
                                          style: TextStyle(
                                            color:
                                            Theme.of(context).colorScheme.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ]),
                        ),
                        // Таби
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(icon: Icon(Icons.description), text: 'Опис'),
                                  Tab(icon: Icon(Icons.videocam), text: 'Трейлери'),
                                  Tab(icon: Icon(Icons.people), text: 'Актори'),
                                  Tab(icon: Icon(Icons.reviews), text: 'Відгуки'),
                                  Tab(icon: Icon(Icons.movie), text: 'Схожі'),
                                ],
                                labelColor: Theme.of(context).colorScheme.primary,
                                unselectedLabelColor:
                                Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                indicatorColor: Theme.of(context).colorScheme.primary,
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorWeight: 3,
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                splashFactory: NoSplash.splashFactory,
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(movie, context),
                        _buildVideosTab(movie, context),
                        _buildCastTab(movie, context),
                        _buildReviewsTab(movie, context),
                        _buildSimilarMoviesTab(movie, context),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
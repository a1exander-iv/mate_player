import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mate_player/presentation/cubits/player/player_cubit.dart';

class ScrollToTopFloatingButton extends StatefulWidget {
  const ScrollToTopFloatingButton({
    super.key,
    required this.scrollController,
    this.isMobilePlaylistScreen,
  });
  final ScrollController scrollController;
  final bool? isMobilePlaylistScreen;
  @override
  State<ScrollToTopFloatingButton> createState() =>
      _ScrollToTopFloatingButtonState();
}

class _ScrollToTopFloatingButtonState extends State<ScrollToTopFloatingButton> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(scrollControllerListener);
  }

  void scrollControllerListener() {
    var offset = widget.scrollController.offset;
    var maxScrollExtent = widget.scrollController.position.maxScrollExtent;
    bool isLargeScreen = MediaQuery.of(context).size.width >= 1200;
    if (offset >= 450 && offset < maxScrollExtent) {
      setState(() {
        _showButton = true;
      });
    } else if (offset == maxScrollExtent && isLargeScreen) {
      setState(() {
        _showButton = true;
      });
    } else {
      setState(() {
        _showButton = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ScrollToTopFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(scrollControllerListener);
      widget.scrollController.addListener(scrollControllerListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (_showButton) {
          return Align(
            alignment: Alignment.bottomRight,
            child: BlocBuilder<PlayerCubit, PlayerCubitState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: 16,
                    bottom:
                        widget.isMobilePlaylistScreen == true &&
                            state.audioPlayerState != PlayerState.stopped
                        ? 72
                        : 8,
                  ),
                  child: FloatingActionButton.small(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onInverseSurface,
                    child: Icon(Icons.arrow_upward),
                    onPressed: () {
                      widget.scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }
}

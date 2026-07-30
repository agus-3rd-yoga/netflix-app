import { useEffect, useRef } from "react";
import type { VideoJsPlayerOptions } from "video.js";
import Player from "video.js/dist/types/player";
import videojs from "video.js";
import "videojs-youtube";
import "video.js/dist/video-js.css";

type VideoJSPlayerOptions = VideoJsPlayerOptions;

export default function VideoJSPlayer({
  options,
  onReady,
}: {
  options: VideoJSPlayerOptions;
  onReady: (player: Player) => void;
}) {
  const videoRef = useRef<HTMLDivElement | null>(null);
  const playerRef = useRef<Player | null>(null);

  useEffect(() => {
    if (!playerRef.current && videoRef.current) {
      const videoElement = document.createElement("video-js");
      videoRef.current.appendChild(videoElement);

      const player = (playerRef.current = videojs(
        videoElement,
        options,
        () => {
          onReady(player);
        }
      ));

      return;
    }

    playerRef.current?.width(options.width);
    playerRef.current?.height(options.height);
  }, [onReady, options]);

  // Dispose the Video.js player when the functional component unmounts
  useEffect(() => {
    return () => {
      const player = playerRef.current;
      if (player && !player.isDisposed()) {
        player.dispose();
        playerRef.current = null;
      }
    };
  }, []);

  return (
    <div data-vjs-player>
      <div ref={videoRef} />
    </div>
  );
}

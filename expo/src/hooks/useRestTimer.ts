import { useState, useEffect, useRef, useCallback } from 'react';

export function useRestTimer(defaultSeconds = 90) {
  const [remaining, setRemaining] = useState(0);
  const [running, setRunning] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const clear = useCallback(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  }, []);

  const start = useCallback(
    (seconds = defaultSeconds) => {
      clear();
      setRemaining(seconds);
      setRunning(true);
      intervalRef.current = setInterval(() => {
        setRemaining((prev) => {
          if (prev <= 1) {
            clear();
            setRunning(false);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    },
    [clear, defaultSeconds],
  );

  const stop = useCallback(() => {
    clear();
    setRunning(false);
    setRemaining(0);
  }, [clear]);

  // Cleanup on unmount
  useEffect(() => () => clear(), [clear]);

  return { remaining, running, start, stop };
}

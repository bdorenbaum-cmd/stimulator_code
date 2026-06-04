% receiver_latency.m
  folder   = 'triggers';                      % <-- the SHARED folder, as this machine sees it
  pingfile = fullfile(folder,'ping.mat');
  pongfile = fullfile(folder,'pong.mat');

  lastseq = -1;
  fprintf('receiver ready, watching %s ...\n', pingfile);
  while true
      if isfile(pingfile)
          try, S = load(pingfile); catch, continue; end   % skip if caught mid-write
          if isfield(S,'seq') && S.seq ~= lastseq
              lastseq = S.seq;
              seq = S.seq;                     %#ok<NASGU>
              save(pongfile,'seq');            % echo back ASAP
              if seq < 0, break; end           % -1 = stop signal
          end
      end
      pause(0.001);                            % 1 ms poll
  end
  fprintf('receiver done\n');
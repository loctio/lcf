function count = generateSnapshotFile(iq_samples, snapshot_file_path)
  
  %generateSnapshotFile creates a snapshot binary file
  %
  % count = generateSnapshotFile(iq_samples, snapshot_file_path)
  % Generates a binary file with path snapshot_file_path, containing the
  % complex samples of the iq_samples column array. I/Q samples shall
  % be represented with only one bit.
  % The total number of samples is recommended to be a multiple integer of
  % four, in order to avoid missing % any of the last samples from the
  % snapshot file.
  %
  % generateSnapshotFile input arguments
  % iq_samples : column array of the complex I/Q samples
  % snapshot_file_path : path to the snapshot binary file
  % generateSnapshotFile output argument
  % count : the number of samples stored
  %
  %Copyright © Loctio 2020
  
  % Check samples number %
  skpd_smpls = mod(size(iq_samples,1), 4);
  if 0 ~= skpd_smpls
    iq_samples = iq_samples(1:end-skpd_smpls);
    warning('Last %d samples are ommited, in order to preserve stored-bytes integrity.', skpd_smpls);
  end
  
  % Read complex samples I/Q parts
  real_part = real(iq_samples);
  imag_part = imag(iq_samples);
  
  % Real part precedes imaginary part
  samples = [real_part imag_part];
  
  % Convert samples to bits, assinging -1 to 1, and 0 to 0
  samples(samples==-1) = 1;
  
  % Re-arrange sample bits to octades (bytes)
  octades = reshape(samples.', 8, []);
  
  % Read bytes as decimal
  decimal = bi2de(octades.', 'right-msb');
  
  % Open snapshot file for writing
  fid = fopen(snapshot_file_path, 'w');
  
  % Write decimals into the snapshot file as unsigned 8-bits integers
  count = fwrite(fid, decimal, 'uint8');
  
  % Close snapshot file
  fclose(fid);
end

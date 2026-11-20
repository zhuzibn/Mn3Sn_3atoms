function hash = mn3sn_sha256(filename)
%MN3SN_SHA256 Hash file bytes without altering the file.
fid=fopen(filename,'rb');
assert(fid>=0,'Mn3Sn:MissingFile','Cannot read %s',filename);
cleanup=onCleanup(@() fclose(fid));
digest=java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid), digest.update(fread(fid,1048576,'*uint8')); end
bytes=typecast(digest.digest(),'uint8');
hash=lower(reshape(dec2hex(bytes,2).',1,[]));
end

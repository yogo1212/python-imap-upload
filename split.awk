#!/usr/bin/awk -f

function next_file(prefix) {
  num=0
  while (num >= 0) {
		filename=prefix "_" num ".mbox";
		if(system("[ ! -e '" filename "' ]") == 0)
			break;

		num++;
	}

	if (num < 0) {
		print "couldn't find unused filename" > "/dev/stderr"
		exit(1)
	}

  return filename;
}

BEGIN{
	# non-idiomatic use of arguments with awk:
	prefix=ARGV[1];
	if (prefix == "") {
		print "prefix can't be empty" > "/dev/stderr"
		exit(1)
	}
	delete ARGV[1]

	split_after=ARGV[2];
	if (prefix == "") {
		print "need a filesize to split after" > "/dev/stderr"
		exit(1)
	}
	delete ARGV[2]
	delete ARGV[1]

	out=next_file(prefix);
	filesize=0;
}
/^From /{
  if(filesize>=split_after){
    close(out);
		out=next_file(prefix);
    filesize=0;
  }
}
{filesize+=length()}
{print > (out)}
# TODO trim input file? avoid re-writing the same mails after crash
# 'fallocate -c -o 0 -l' length()

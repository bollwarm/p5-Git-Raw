MODULE = Git::Raw			PACKAGE = Git::Raw::Repository

Repository
init(class, path, is_bare)
	SV *class
	SV *path
	unsigned is_bare

	CODE:
		STRLEN len;
		Repository r;
		const char *path_str = SvPVbyte(path, len);

		int rc = git_repository_init(&r, path_str, is_bare);
		git_check_error(rc);

		RETVAL = r;

	OUTPUT: RETVAL

Repository
open(class, path)
	SV *class
	SV *path

	CODE:
		STRLEN len;
		Repository r;
		const char *path_str = SvPVbyte(path, len);

		int rc = git_repository_open(&r, path_str);
		git_check_error(rc);

		RETVAL = r;

	OUTPUT: RETVAL

Config
config(self)
	Repository self

	CODE:
		Config cfg;

		int rc = git_repository_config(&cfg, self);
		git_check_error(rc);

		RETVAL = cfg;

	OUTPUT: RETVAL

Index
index(self)
	Repository self

	CODE:
		Index out;

		int rc = git_repository_index(&out, self);
		git_check_error(rc);

		RETVAL = out;

	OUTPUT: RETVAL

SV *
lookup(self, id)
	Repository self
	SV *id

	CODE:
		STRLEN len;
		git_oid oid;
		git_object *o;

		int rc = git_oid_fromstrn(&oid, SvPVbyte(id, len), len);
		git_check_error(rc);

		rc = git_object_lookup_prefix(&o, self, &oid, len, GIT_OBJ_ANY);
		git_check_error(rc);

		RETVAL = git_obj_to_sv(o);

	OUTPUT: RETVAL

Commit
commit(self, msg, author, cmtter, parents, tree)
	Repository self
	SV *msg
	Signature author
	Signature cmtter
	AV *parents
	Tree tree

	CODE:
		Commit c;
		STRLEN len;
		git_oid oid;

		int rc = git_commit_create(
			&oid, self, "HEAD",
			author, cmtter, NULL,
			SvPVbyte(msg, len), tree,
			0, NULL
		);
		git_check_error(rc);

		rc = git_commit_lookup(&c, self, &oid);
		git_check_error(rc);

		RETVAL = c;

	OUTPUT: RETVAL

Tag
tag(self, name, msg, tagger, target)
	Repository self
	SV *name
	SV *msg
	Signature tagger
	SV *target

	CODE:
		Tag t;
		git_oid oid;
		git_object *o;
		STRLEN len1, len2;

		o = git_sv_to_obj(target);

		if (o == NULL)
			Perl_croak(aTHX_ "target is not of a valid type");

		int rc = git_tag_create(
			&oid, self, SvPVbyte(name, len1),
			o, tagger, SvPVbyte(msg, len2), 0
		);
		git_check_error(rc);

		rc = git_tag_lookup(&t, self, &oid);
		git_check_error(rc);

		RETVAL = t;

	OUTPUT: RETVAL

SV *
path(self)
	Repository self

	CODE:
		const char *path = git_repository_path(self);
		RETVAL = newSVpv(path, 0);

	OUTPUT: RETVAL

SV *
workdir(self)
	Repository self

	CODE:
		const char *path = git_repository_workdir(self);
		RETVAL = newSVpv(path, 0);

	OUTPUT: RETVAL

bool
is_bare(self)
	Repository self

	CODE:
		RETVAL = git_repository_is_bare(self);

	OUTPUT: RETVAL

bool
is_empty(self)
	Repository self

	CODE:
		RETVAL = git_repository_is_empty(self);

	OUTPUT: RETVAL

void
DESTROY(self)
	Repository self

	CODE:
		git_repository_free(self);

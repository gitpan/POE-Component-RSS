# $Id: Makefile.PL 550 2005-08-23 03:35:31Z sungo $
use inc::Module::Install;

name         ('POE-Component-RSS');
author       ('Matt Cashner (sungo@pobox.com)');
version_from ('VERSION');
license      ('bsd');

requires ('POE');
requires ('XML::RSS');
requires ('Test::More');
requires ('Params::Validate');

sign(1);

WriteAll();


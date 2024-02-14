/*
 # This file is part of the Astrometry.net suite.
 # Licensed under a 3-clause BSD style license - see LICENSE
 */

#ifndef AN_INDEXSET_H
#define AN_INDEXSET_H

#include "index.h"
#include "an-bool.h"
#include "anqfits.h"
#include "bl.h"

void indexset_get(const char* name, pl* indexlist);

#endif

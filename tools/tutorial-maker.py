#!/usr/bin/python

import json

def generate_verb_file(canonical_name, similar_verbs, synonyms, version_mappings):
    obj = {}
    obj['canonical_name'] = canonical_name
    obj['similar_verbs'] = similar_verbs
    obj['synonyms'] = synonyms
    obj['version_mappings'] = version_mappings
    return json.dumps(obj, indent=2, separators=(',', ': '))

print generate_verb_file('open-file', ['create-file', 'write-file'], ['read-file', 'read-from-file'], [])

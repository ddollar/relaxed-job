function(doc) {
  if (doc.class == 'job' && doc.state == 'locked') {
    emit(doc.locked_by, doc);
  }
}
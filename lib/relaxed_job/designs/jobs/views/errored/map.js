function(doc) {
  if (doc.class == 'job' && doc.state == 'error') {
    emit(doc.errored_at, doc);
  }
}
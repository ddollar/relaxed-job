function(doc) {
  if (doc.class == 'job' && doc.state == 'pending') {
    emit(doc.queued_at, doc);
  }
}
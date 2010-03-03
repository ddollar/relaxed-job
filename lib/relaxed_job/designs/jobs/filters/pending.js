function(doc, req) {
  if (doc.class == 'job' && doc.state == 'pending') {
    return(true);
  }
}
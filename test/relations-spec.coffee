describe "relations functionality:", ->
  $rootScope = undefined
  $httpBackend = undefined
  $q = undefined
  Resource = undefined
  Book = undefined
  Author = undefined

  beforeEach module("restOrm")

  beforeEach inject(($injector) ->
    $rootScope = $injector.get("$rootScope")
    $httpBackend = $injector.get("$httpBackend")
    $q = $injector.get("$q")
    Resource = $injector.get("Resource")
  )

  describe "Resource.Get()", ->
    it "should fetch reference relations", ->
      class Author extends Resource
        @urlEndpoint: '/api/v1/authors/'
        @defaults:
          name: ""
      class Book extends Resource
        @urlEndpoint: '/api/v1/books/'
        @references: [{name: 'author', model: Author}]
        @defaults:
          title: ""
          author: null

      $httpBackend.expect('GET', '/api/v1/books/1').respond(200, { id: 1, title: "Moby Dick", author: 2 } )
      $httpBackend.expect('GET', '/api/v1/authors/2').respond(200, { id: 2, name: "Herman Melville" } )

      book = Book.Get(1)

      book.$promise.then ->
        expect(book).toBeDefined()
        expect(book instanceof Book).toBeTruthy()
        expect(book.$id).toEqual(1)
        expect(book.title).toEqual("Moby Dick")
        expect(book.author).toBeDefined()
        expect(book.author instanceof Author).toBeTruthy()
        expect(book.author.$id).toEqual(2)
        expect(book.author.name).toEqual("Herman Melville")

      $rootScope.$digest()
      $httpBackend.flush()
      return

    it "should fetch many-to-many relations", ->
      class Tag extends Resource
        @urlEndpoint: '/api/v1/tags/'
        @defaults:
          name: ""
      class Book extends Resource
        @urlEndpoint: '/api/v1/books/'
        @m2m: [{name: 'tags', model: Tag}]
        @defaults:
          title: ""
          tag: null

      $httpBackend.expect('GET', '/api/v1/books/1').respond(200, { id: 1, title: "Moby Dick", tags: [2, 5] } )
      $httpBackend.expect('GET', '/api/v1/tags/2').respond(200, { id: 2, name: "novel" } )
      $httpBackend.expect('GET', '/api/v1/tags/5').respond(200, { id: 5, name: "fiction" } )

      book = Book.Get(1)

      book.$promise.then ->
        expect(book).toBeDefined()
        expect(book instanceof Book).toBeTruthy()
        expect(book.$id).toEqual(1)
        expect(book.title).toEqual("Moby Dick")
        expect(book.tags).toBeDefined()
        expect(angular.isArray(book.tags)).toBeTruthy()
        expect(book.tags.length).toEqual(2)
        expect(book.tags[0] instanceof Tag).toBeTruthy()
        expect(book.tags[0].$id).toEqual(2)
        expect(book.tags[0].name).toEqual("novel")
        expect(book.tags[1] instanceof Tag).toBeTruthy()
        expect(book.tags[1].$id).toEqual(5)
        expect(book.tags[1].name).toEqual("fiction")

      $rootScope.$digest()
      $httpBackend.flush()
      return

    return

  return

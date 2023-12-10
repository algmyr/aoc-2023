module my_personal_aoc_hell
  implicit none

  type :: t_map
    integer :: width
    integer :: height
    character(len=:), allocatable :: data
    contains
      procedure :: get
      procedure :: inside
      procedure :: set
  end type
contains
  subroutine set(self, x, y, value)
    ! Set value at x, y.
    class(t_map), intent(inout) :: self
    integer, intent(in) :: x, y
    character, intent(in) :: value
    integer :: idx

    idx = (y - 1)*(self%width + 1) + x
    self%data(idx:idx) = value
  end subroutine

  character function get(self, x, y) result(res)
    ! Get value at x, y, or '.' if out of bounds.
    class(t_map), intent(in) :: self
    integer, intent(in) :: x, y
    integer :: idx
    if (self%inside(x, y)) then
      idx = (y - 1)*(self%width + 1) + x
      res = self%data(idx:idx)
    else
      res = '.'
    endif
  end function

  logical function inside(self, x, y)
    ! Check if x, y is inside the map.
    class(t_map), intent(in) :: self
    integer, intent(in) :: x, y
    inside = 1 <= x .and. x <= self%width .and. 1 <= y .and. y <= self%height
  end function

#define WEST_FACING "-J7"
#define EAST_FACING "-LF"
#define NORTH_FACING "|JL"
#define SOUTH_FACING "|7F"

  logical function can_left(cur, next)
    character, intent(in) :: cur, next
    can_left = (index(WEST_FACING, cur) > 0 .and. index(EAST_FACING, next) > 0)
  end function

  logical function can_right(cur, next)
    character, intent(in) :: cur, next
    can_right = (index(EAST_FACING, cur) > 0 .and. index(WEST_FACING, next) > 0)
  end function

  logical function can_up(cur, next)
    character, intent(in) :: cur, next
    can_up = (index(NORTH_FACING, cur) > 0 .and. index(SOUTH_FACING, next) > 0)
  end function

  logical function can_down(cur, next)
    character, intent(in) :: cur, next
    can_down = (index(SOUTH_FACING, cur) > 0 .and. index(NORTH_FACING, next) > 0)
  end function

  recursive subroutine dfs_mark_reachable_impl(board, x, y, target_x, target_y, visited, reachable)
    implicit none
    type(t_map), intent(in) :: board
    integer, intent(in) :: x, y, target_x, target_y
    logical, intent(inout) :: visited(board%width, board%height)
    logical, intent(inout) :: reachable(board%width, board%height)
    character :: cur

    if (x == target_x .and. y == target_y) then
      reachable(x, y) = .true.
      return
    endif
    if (visited(x, y)) then
      return
    endif
    visited(x, y) = .true.
    cur = board%get(x, y)

#define TRY_STEP(check, new_x, new_y) \
    if (check(cur, board%get(new_x, new_y))) then; \
      call dfs_mark_reachable_impl(board, new_x, new_y, target_x, target_y, visited, reachable); \
      if (reachable(new_x, new_y)) then; \
        reachable(x, y) = .true.; \
      endif; \
    endif

    TRY_STEP(can_left, x-1, y)
    TRY_STEP(can_right, x+1, y)
    TRY_STEP(can_up, x, y-1)
    TRY_STEP(can_down, x, y+1)
  end subroutine

  function dfs_mark_reachable(board, x, y, c, ok) result(reachable)
    type(t_map), intent(in) :: board
    logical :: reachable(board%width, board%height)
    logical :: visited(board%width, board%height)
    integer, intent(in) :: x, y
    character, intent(in) :: c
    logical, intent(out) :: ok

    integer :: start_x, start_y, end_x, end_y
    character(3) :: start_facing, end_facing

#define XPASTE(s) s
#define PASTE(a, b) XPASTE(a)b
#define NORTH(s) PASTE(s,x) = x;   PASTE(s,y) = y-1; PASTE(s,facing) = SOUTH_FACING
#define SOUTH(s) PASTE(s,x) = x;   PASTE(s,y) = y+1; PASTE(s,facing) = NORTH_FACING
#define EAST(s)  PASTE(s,x) = x+1; PASTE(s,y) = y;   PASTE(s,facing) = WEST_FACING
#define WEST(s)  PASTE(s,x) = x-1; PASTE(s,y) = y;   PASTE(s,facing) = EAST_FACING

    if (c == 'L') then
      NORTH(start_); EAST(end_)
    elseif (c == 'J') then
      NORTH(start_); WEST(end_)
    elseif (c == '7') then
      SOUTH(start_); WEST(end_)
    elseif (c == 'F') then
      SOUTH(start_); EAST(end_)
    elseif (c == '|') then
      NORTH(start_); SOUTH(end_)
    elseif (c == '-') then
      EAST(start_); WEST(end_)
    else
      stop 1
    endif

    ok = (index(start_facing, board%get(start_x, start_y)) > 0 .and. index(end_facing, board%get(end_x, end_y)) > 0)

    if (.not. ok) then
      return
    endif

    if (.not. board%inside(start_x, start_y) .or. .not. board%inside(end_x, end_y)) then
      ok = .false.
      return
    endif

    visited = .false.
    reachable = .false.
    reachable(x, y) = .true.
    call dfs_mark_reachable_impl(board, start_x, start_y, end_x, end_y, visited, reachable)
    ok = reachable(end_x, end_y)
  end function

  integer function count_reachable(reachable) result(res)
    logical, intent(in) :: reachable(:,:)
    integer :: x, y
    res = 0
    do y = 1, size(reachable, 2)
      do x = 1, size(reachable, 1)
        if (reachable(x, y)) then
          res = res + 1
        endif
      enddo
    enddo
  end function

  integer function compute_row_area(board, reachable, y) result(res)
    type(t_map), intent(in) :: board
    integer, intent(in) :: y
    logical, intent(in) :: reachable(:, :)
    integer :: x
    logical :: up, down, inside
    character :: cur
    up = .false.
    down = .false.
    inside = .false.
    res = 0
    do x = 1, board%width
      if (.not. reachable(x, y)) then
        if (inside) then
          res = res + 1
        endif
        cycle
      endif
      cur = board%get(x, y)
      if (cur == '|') then
        inside = .not. inside
        up = .false.
        down = .false.
      elseif (cur == 'F') then
        down = .true.
      elseif (cur == 'L') then
        up = .true.
      elseif (cur == '7') then
        if (up) then
          inside = .not. inside
        endif
        up = .false.
        down = .false.
      elseif (cur == 'J') then
        if (down) then
          inside = .not. inside
        endif
        up = .false.
        down = .false.
      endif
    enddo
  end function

  integer function compute_area(board, reachable) result(res)
    type(t_map), intent(in) :: board
    logical, intent(in) :: reachable(:, :)
    integer :: y
    res = 0
    do y = 1, board%height
      res = res + compute_row_area(board, reachable, y)
    enddo
  end function

  subroutine solve(board)
    implicit none
    type(t_map), intent(inout) :: board
    integer start_x, start_y, x, y
    logical :: reachable(board%width, board%height)
    logical :: ok
    character(6) :: types
    integer :: i

    start_x = -1
    start_y = -1
    do y = 1, board%height
      do x = 1, board%width
        if (board%get(x, y) == 'S') then
          start_x = x
          start_y = y
        endif
      enddo
    enddo

    types = "|-LJ7F"
    do i = 1, len(types)
      ! DFS to find things that are loops, given start and assumed type.
      reachable = dfs_mark_reachable(board, start_x, start_y, types(i:i), ok)
      if (ok) then
        ! Distance is #reachable / 2
        print '(A, I4)', "Part 1: ", count_reachable(reachable)/2
        ! Area can be computed based on reachable and board, filling in the gap.
        call board%set(start_x, start_y, types(i:i))
        print '(A, I4)', "Part 2: ", compute_area(board, reachable)
        call board%set(start_x, start_y, 'S')
      endif
    enddo
  end subroutine
end module

program aoc
  use my_personal_aoc_hell
  implicit none

  character(ishft(1, 16)) :: map_data
  character(ishft(1, 8)) :: buffer
  character(len=:), allocatable :: line
  integer :: width, height
  type(t_map) :: board

  map_data = ''
  height = 0
  do while (.true.)
    read (*, '(A)', end=99) buffer
    line = trim(buffer)
    height = height + 1
    width = len(line)
    map_data = trim(map_data) // line // char(10)
  enddo
  99 continue

  board%width = width
  board%height = height
  board%data = map_data

  call solve(board)
end program

! Declare a module for reaction rate (and other parameter) perturbations.
!
! CSV format expected (either comma-separated or whitespace-separated):
!   <key>, <value>
! Example:
!   n2++o=>no++n2d+op70ev=>no++n4s+3p08ev_lt, 1.33e-16
!   Ko_NO, 3.6e-17
!
module ModReactionRatePerturb

  use ModInputs,  only: cReactionRateFile
  use ModKind,    only: Real8_

  implicit none

  integer, parameter :: nRatesMax = 200

  logical :: IsLoaded = .false.
  integer :: nRates = 0

  real(Real8_), dimension(nRatesMax) :: PerturbedRates
  character(len=200), dimension(nRatesMax) :: Keys

contains

  subroutine read_csvfile()
    implicit none

    integer :: iUnit, ios
    character(len=400) :: line
    character(len=200) :: key
    real(Real8_) :: value

    ! Reset
    nRates = 0

    if (trim(cReactionRateFile) == 'none') then
       write(*,*) 'ModReactionRatePerturb: cReactionRateFile is "none". Cannot read rates.'
       IsLoaded = .false.
       return
    end if

    iUnit = 10
    open(iUnit, file=trim(cReactionRateFile), status='old', action='read', iostat=ios)
    if (ios /= 0) then
      write(*,*) 'Error opening reaction/parameter CSV file: ', trim(cReactionRateFile)
      stop
    end if

    ! Header for checking
    write(*,*) 'Reading reaction/parameter rates from: ', trim(cReactionRateFile)
    write(*,*) 'Key                              Value'
    write(*,*) '--------------------------------------------'

    do
      read(iUnit,'(A)',iostat=ios) line
      if (ios /= 0) exit

      ! Skip blank lines and comment lines (# or ! in column 1)
      if (len_trim(line) == 0) cycle
      if (line(1:1) == '#' .or. line(1:1) == '!') cycle

      key = ''
      value = 0.0_Real8_

      ! List-directed read supports comma or whitespace
      read(line,*,iostat=ios) key, value
      if (ios /= 0) then
        write(*,*) 'Error parsing line in ', trim(cReactionRateFile)
        write(*,*) 'Line was: ', trim(line)
        stop
      end if

      nRates = nRates + 1
      if (nRates > nRatesMax) then
        write(*,*) 'Too many entries in ', trim(cReactionRateFile), ' (increase nRatesMax)'
        stop
      end if

      Keys(nRates) = adjustl(key)
      PerturbedRates(nRates) = value

      ! Print each entry for verification
      write(*,'(A30,2X,ES22.15)') trim(Keys(nRates)), PerturbedRates(nRates)

    end do

    close(iUnit)
    IsLoaded = .true.

    write(*,*) '--------------------------------------------'
    write(*,*) 'Total entries loaded = ', nRates

  end subroutine read_csvfile


  subroutine get_reaction_rate(reaction, rate)

    character(len=*), intent(in) :: reaction
    real(Real8_),     intent(out) :: rate

    integer :: i
    logical :: IsFound

    if (.not. IsLoaded) call read_csvfile()

    IsFound = .false.

    do i = 1, nRates
      if (trim(reaction) == trim(Keys(i))) then
        rate = PerturbedRates(i)
        IsFound = .true.
        exit
      end if
    end do

    if (.not. IsFound) then
      rate = -1.0e32_Real8_
      write(*,*) 'ModReactionRatePerturb: could not find key: ', trim(reaction)
    end if

  end subroutine get_reaction_rate


  subroutine reload_reaction_rate_file()
    IsLoaded = .false.
    call read_csvfile()
  end subroutine reload_reaction_rate_file

end module ModReactionRatePerturb
